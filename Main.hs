{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

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

download_dir = "/volume1/homes/transmission/"
host = "192.168.1.43"

base_dir = "/home/m/downloads/torrents"
new_dir = base_dir </> "new"
failed_dir = base_dir </> "failed"
done_dir = base_dir </> "done"

main :: IO ()
main = do
  torrents <- find always (fileType ==? RegularFile &&? extension ==? ".torrent") new_dir
  forM_ torrents $ \torrent -> do
    BSC.putStr $ BSC.pack $ "processing " ++ torrent ++ " :"
    result <- process torrent
    BSC.putStrLn $ BSC.pack $ show result
    case result of
      True   -> moveTo done_dir torrent
      False  -> moveTo failed_dir torrent
 where
  moveTo :: FilePath -> FilePath -> IO ()
  moveTo dir torrent = renameFile torrent (dir </> (takeFileName torrent))

process :: FilePath -> IO Bool
process torrentFile = do
  torrent <- BS.readFile torrentFile
  case view tAnnounce <$> decode torrent of
    Left e -> do
      BSC.putStr $ BSC.pack e
      return False
    Right uri -> do
      case trackerSuffix =<< uriRegName <$> (uriAuthority =<< parseURI (BSC.unpack uri)) of
        Just s -> do
          handle (\(SomeException _) -> return False) $ do
            callProcess "transmission-remote"
              [ host
              , "--add",  torrentFile
              , "--download-dir", download_dir ++ s
              ]
            return True
        Nothing -> return True

trackerSuffix :: String -> Maybe String
trackerSuffix s = case s of
  "please.passthepopcorn.me" -> Just "ptp"
  "tracker.broadcasthe.net" -> Just "btn"
  "tracker.what.cd" -> Just "whatcome"
  "www.mutracker.org" -> Just "outcome"
  "x264.me" -> Just "x264"
  _ -> Nothing
