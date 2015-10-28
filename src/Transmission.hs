{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Transmission
  ( send
  ) where

import           Control.Exception
import           Control.Lens
import           Data.BEncode
import qualified Data.ByteString                 as BS
import qualified Data.ByteString.Char8           as BSC
import qualified Data.Map                        as Map
import           Data.Maybe                      (fromMaybe)
import           Network.HsTorrent.TorrentParser
import           Network.URI
import           System.FilePath                 ((</>))
import           System.Process

import           Config

-- | Send request with given torrent to remove transmission client, return Maybe error
send :: TransmissionConfig -> FilePath -> IO (Maybe BSC.ByteString)
send config torrentFilePath = do
  torrent <- BS.readFile torrentFilePath
  case view tAnnounce <$> decode torrent of
    Left e -> return $ Just $ BSC.pack e
    Right uri -> handle (\(SomeException e) -> return $ Just $ BSC.pack $ show e) $ do
        let args = [ host config
                   , "--add",  torrentFilePath
                   , "--download-dir", (downloadDirPrefix config) </> (fromMaybe "misc" $ flip Map.lookup (trackers config) =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack uri)))
                   ]
        let argsWithCred = case auth config of
                             Just (Credentials u p) -> args ++ [ "--auth=" ++ u ++ ":" ++ p ]
                             Nothing -> args
        callProcess "transmission-remote" argsWithCred
        return Nothing
