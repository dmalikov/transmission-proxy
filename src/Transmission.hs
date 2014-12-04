{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module Transmission
  ( send
  ) where

import           Control.Applicative
import           Control.Exception
import           Control.Lens
import           Data.BEncode
import qualified Data.ByteString                 as BS
import qualified Data.ByteString.Char8           as BSC
import qualified Data.Map                        as Map
import           Network.HsTorrent.TorrentParser
import           Network.URI
import           System.Process

import           Config


-- | Send request with given torrent to remove transmission client, return Maybe error
send :: TransmissionConfig -> FilePath -> IO (Maybe BSC.ByteString)
send (TransmissionConfig host downloadDirPrefix organizer) torrentFilePath = do
  torrent <- BS.readFile torrentFilePath
  case view tAnnounce <$> decode torrent of
    Left e -> return $ Just $ BSC.pack e
    Right uri ->
      case flip Map.lookup organizer =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack uri)) of
        Just s ->
          handle (\(SomeException e) -> return $ Just $ BSC.pack $ show e) $ do
            callProcess "transmission-remote"
              [ host
              , "--add",  torrentFilePath
              , "--download-dir", downloadDirPrefix ++ s
              ]
            return Nothing
        Nothing -> return $ Just $ "no such tracker " `BSC.append` uri
