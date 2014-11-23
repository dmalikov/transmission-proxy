{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module Transmission
  ( send
  , Config(..)
  ) where


import           Control.Applicative
import           Control.Exception
import           Control.Lens
import           Control.Monad
import           Data.BEncode
import qualified Data.ByteString                 as BS
import qualified Data.ByteString.Char8           as BSC
import           Network.HsTorrent.TorrentParser
import           Network.URI
import           System.Directory
import           System.Environment
import           System.FilePath
import           System.FilePath.Find
import           System.FilePath.Posix
import           System.Process

-- | Some transmission-remote arguments
data Config = Config
  { host :: String                -- IP or hostname of a server where transmission-remote works, TODO ip address type?
  , downloadDirPrefix :: FilePath -- first part of `--download-dir` argument, second is based on the torrent tracker
  }

send :: Config -> FilePath -> IO Bool
send (Config host downloadDirPrefix) torrentFilePath = do
  torrent <- BS.readFile torrentFilePath
  case view tAnnounce <$> decode torrent of
    Left e -> do
      BSC.putStr $ BSC.pack e
      return False
    Right uri ->
      case trackerSuffix =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack uri)) of
        Just s ->
          handle (\(SomeException _) -> return False) $ do
            callProcess "transmission-remote"
              [ host
              , "--add",  torrentFilePath
              , "--download-dir", downloadDirPrefix ++ s
              ]
            return True
        Nothing -> return True

-- TODO read from config
-- TODO from Torrent itself, not from a string
trackerSuffix :: String -> Maybe String
trackerSuffix s = case s of
  "please.passthepopcorn.me" -> Just "ptp"
  "tracker.broadcasthe.net" -> Just "btn"
  "tracker.what.cd" -> Just "whatcome"
  "www.mutracker.org" -> Just "outcome"
  "x264.me" -> Just "x264"
  _ -> Nothing
