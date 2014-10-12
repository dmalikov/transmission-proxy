{-# LANGUAGE OverloadedStrings #-}

import           Control.Applicative
import           Control.Lens
import           Data.BEncode
import qualified Data.ByteString                 as BS
import qualified Data.ByteString.Char8           as BSC
import           Network.HsTorrent.TorrentParser
import           Network.URI
import           System.Environment
import           System.Process


main :: IO ()
main = do
  torrentFile <- parseArgs
  torrent <- BS.readFile torrentFile
  case view tAnnounce <$> decode torrent of
    Left e -> error e
    Right uri -> do
      BSC.putStrLn ("Torrent announce: " `BSC.append` uri)
      case trackerSuffix =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack uri)) of
        Just s -> do
          callProcess "transmission-remote"
            [ "192.168.1.33"
            , "--add",  torrentFile
            , "--download-dir", "/mnt/wdt/" ++ s
            ]
        Nothing -> putStrLn "unknown tracker"


parseArgs :: IO FilePath
parseArgs = do
  args <- getArgs
  case args of
    (x:_) -> return x
    _ -> error "undefined torrent file"

trackerSuffix :: String -> Maybe String
trackerSuffix s = case s of
  "please.passthepopcorn.me" -> Just "ptp"
  "tracker.broadcasthe.net" -> Just "btn"
  "tracker.what.cd" -> Just "whatcome"
  "www.mutracker.org" -> Just "outcome"
  "x264.me" -> Just "x264"
  _ -> Nothing
