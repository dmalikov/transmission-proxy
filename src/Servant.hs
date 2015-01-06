{-# LANGUAGE OverloadedStrings #-}
module Servant (startServing) where

import           Control.Concurrent        (threadDelay)
import           Control.Monad
import qualified Data.ByteString.Char8     as BSC
import qualified Filesystem.Path           as FSP
import qualified Filesystem.Path.CurrentOS as FPCOS
import           Prelude                   hiding (and)
import           System.Directory
import           System.FilePath
import           System.FilePath.Find
import           System.FSNotify

import           Config
import           Transmission

-- | Check given directory for a unserved torrents and start watching it
startServing :: Config -> IO ()
startServing config@(Config baseDir _) = do
  check baseDir
  torrents <- find (depth ==? 0) (fileType ==? RegularFile &&? extension ==? ".torrent") baseDir
  BSC.putStrLn $ BSC.concat
    [ "Found "
    , BSC.pack $ show $ length torrents
    , " torrents"
    ]
  forM_ torrents $ serve config
  withManagerConf WatchConfig { confPollInterval = 1000000
                              , confDebounce = DebounceDefault
                              , confUsePolling = False
                              }
                  $ \mgr -> do
    _ <- watchDir
      mgr
      (FPCOS.decodeString baseDir)
      (isAdded `and` isTorrent)
      (\event -> do
        print event
        serve config $ FPCOS.encodeString $ eventPath event)
    forever $ threadDelay maxBound

-- bunch of local helpers

isAdded :: ActionPredicate
isAdded (Added _ _) = True
isAdded          _  = False

isTorrent :: ActionPredicate
isTorrent event = FSP.extension (eventPath event) == Just "torrent"

and :: ActionPredicate -> ActionPredicate -> ActionPredicate
a `and` b = \event -> a event && b event

failedDir, doneDir :: FilePath -> FilePath
failedDir baseDir = baseDir </> "failed"
doneDir baseDir = baseDir </> "done"

serve :: Config -> FilePath -> IO ()
serve (Config baseDir transmissionConfig) torrent = do
    let filename = BSC.pack $ takeFileName torrent
    torrentAccepted <- send transmissionConfig torrent
    case torrentAccepted of
      Just e -> do
        BSC.putStrLn $ BSC.concat [ filename, " failed (", e, ")" ]
        moveTo (failedDir baseDir) torrent
      Nothing -> do
        BSC.putStrLn $ BSC.concat [ filename, " done" ]
        moveTo (doneDir baseDir) torrent

moveTo :: FilePath -> FilePath -> IO ()
moveTo dir torrent = renameFile torrent (dir </> takeFileName torrent)

check :: FilePath -> IO ()
check baseDir = do
  baseDirectoryExists <- doesDirectoryExist baseDir
  unless baseDirectoryExists $ error $ "No such baseDir " ++ baseDir
  forM_ [failedDir baseDir, doneDir baseDir] $ \d -> do
    dirExists <- doesDirectoryExist d
    unless dirExists $ createDirectory d
