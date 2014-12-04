{-# LANGUAGE OverloadedStrings #-}

module Servant (serve) where

import           Control.Monad
import qualified Data.ByteString.Char8 as BSC
import           System.Directory
import           System.FilePath
import           System.FilePath.Find

import           Config
import           Transmission

newDir, failedDir, doneDir :: FilePath -> FilePath
newDir baseDir = baseDir
failedDir baseDir = baseDir </> "failed"
doneDir baseDir = baseDir </> "done"

serve :: Config -> IO ()
serve (Config baseDir transmissionConfig) = do
  check baseDir
  torrents <- find (depth ==? 0) (fileType ==? RegularFile &&? extension ==? ".torrent") (newDir baseDir)
  BSC.putStrLn $ BSC.pack $ show (length torrents) ++ " torrents will be processed"
  forM_ torrents $ \torrent -> do
    BSC.putStrLn $ BSC.pack $ takeFileName torrent
    torrentAccepted <- send transmissionConfig torrent
    case torrentAccepted of
      Just e -> do
        BSC.putStrLn e
        moveTo (failedDir baseDir) torrent
      Nothing ->
        moveTo (failedDir baseDir) torrent

moveTo :: FilePath -> FilePath -> IO ()
moveTo dir torrent = renameFile torrent (dir </> takeFileName torrent)

check :: FilePath -> IO ()
check baseDir = do
  baseDirectoryExists <- doesDirectoryExist baseDir
  unless baseDirectoryExists $ error $ "No such baseDir " ++ baseDir
  forM_ [failedDir baseDir, doneDir baseDir] $ \d -> do
    dirExists <- doesDirectoryExist d
    unless dirExists $ createDirectory d
