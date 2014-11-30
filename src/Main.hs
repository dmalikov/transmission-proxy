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

import           Transmission

config :: Config
config = Config
  { downloadDirPrefix = "/volume1/homes/transmission/"
  , host = "192.168.1.43"
  }

baseDir = "/home/m/downloads/torrents"
newDir = baseDir </> "new"
failedDir = baseDir </> "failed"
doneDir = baseDir </> "done"

main :: IO ()
main = do
  torrents <- find always (fileType ==? RegularFile &&? extension ==? ".torrent") newDir
  forM_ torrents $ \torrent -> do
    BSC.putStr $ BSC.pack $ "processing " ++ torrent ++ " :"
    torrentAccepted <- send config torrent
    moveTo (if torrentAccepted then doneDir else failedDir) torrent
 where
  moveTo :: FilePath -> FilePath -> IO ()
  moveTo dir torrent = renameFile torrent (dir </> takeFileName torrent)

