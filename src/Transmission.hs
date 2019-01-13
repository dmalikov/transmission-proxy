{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Transmission
  ( send
  ) where

import           Control.Lens hiding ((.=))
import           Data.Aeson
import qualified Data.BEncode as BT
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Char8 as BSC
import qualified Data.ByteString.Lazy as BSL
import qualified Data.HashMap.Strict as HM
import           Data.Maybe (fromMaybe, listToMaybe)
import           Network.HsTorrent.TorrentParser
import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Network.HTTP.Types.Header
import           Network.HTTP.Types.Status
import           Network.URI
import           System.FilePath ((</>))

import qualified Config as C

-- TODO introduce proper client

-- Return Just error in case of failure, return nothing in case of success
send :: C.TransmissionConfig -> FilePath -> IO (Maybe BS.ByteString)
send config torrentFilePath = do
  torrent <- BS.readFile torrentFilePath
  case BT.decode torrent of
    Left e -> return $ Just $ BSC.pack e
    Right metainfo -> do
      manager <- newManager tlsManagerSettings -- TODO reuse connection
      initRequest <- parseRequest (C.host config ++ "/rpc/")
      let headers :: [Header] =
            case C.auth config of
              Just (C.Credentials u p) ->
                [ ("Authorization", "Basic " `BS.append` B64.encode (BS.concat [BSC.pack u, ":", BSC.pack p] )) ]
              Nothing -> []
      let ta = TorrentAdd
                 { _downloadDir = C.downloadDirPrefix config </> fromMaybe "misc" (flip HM.lookup (C.trackers config) =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack (view tAnnounce metainfo))))
                 , _torrent = B64.encode torrent
                 }
      let request = initRequest
                      { method = "POST"
                      , requestHeaders = headers
                      , requestBody = (RequestBodyBS . BSL.toStrict . encode) ta
                      }
      response <- httpLbs request manager
      finalResponse <-
        case getFirst sessionIdHeader (responseHeaders response) of
          Just sessionId ->
            let requestWithSessionId = request { requestHeaders = (sessionIdHeader, sessionId) : headers }
            in  httpLbs requestWithSessionId manager
          Nothing -> return response
      if responseStatus finalResponse == ok200
        then return Nothing
        else (return . Just . statusMessage . responseStatus) finalResponse

sessionIdHeader :: HeaderName
sessionIdHeader = "X-Transmission-Session-Id"

-- TODO lensify
getFirst :: Eq a => a -> [(a,b)] -> Maybe b
getFirst x = listToMaybe . map snd . filter ((== x) . fst)

-- TODO move to model
data TorrentAdd
   = TorrentAdd
   { _downloadDir :: FilePath
   , _torrent     :: BS.ByteString
   }

instance ToJSON TorrentAdd where
  toJSON (TorrentAdd downloadDir torrent) = object
     [ "arguments" .= object
       [ "download-dir" .= downloadDir
       , "metainfo" .= BSC.unpack torrent
       ]
     , "method" .= ("torrent-add" :: String)
     , "tag" .= (8 :: Int)
     ]
