{-# LANGUAGE OverloadedStrings #-}
module Servant (startServing) where

import           Control.Concurrent    (threadDelay)
import           Control.Monad
import qualified Data.ByteString.Char8 as BSC
import           Prelude               hiding (and)
import           System.Directory
import           System.FilePath
import           System.FilePath.Find
import           System.FSNotify

import           Config
import           Transmission

-- | Check given directory for unserved torrents and start watching it
startServing :: Config -> IO ()
startServing config = do
  check $ baseDir config
  torrents <- find (depth ==? 0) (fileType ==? RegularFile &&? extension ==? ".torrent") $ baseDir config
  BSC.putStrLn $ BSC.unlines [ "Using config:", BSC.pack $ show config ]
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
      (baseDir config)
      (isAdded `and` isTorrent)
      (\event -> do
        print event
        serve config $ eventPath event)
    forever $ threadDelay maxBound

-- bunch of local helpers

isAdded :: ActionPredicate
isAdded (Added _ _) = True
isAdded          _  = False

isTorrent :: ActionPredicate
isTorrent event = takeExtension (eventPath event) == ".torrent"

and :: ActionPredicate -> ActionPredicate -> ActionPredicate
a `and` b = \event -> a event && b event

failedDir, doneDir :: FilePath -> FilePath
failedDir = (</> "failed")
doneDir   = (</> "done")

serve :: Config -> FilePath -> IO ()
serve config torrent = do
    let filename = BSC.pack $ takeFileName torrent
    torrentAccepted <- send (transmission config) torrent
    case torrentAccepted of
      Just e -> do
        BSC.putStrLn $ BSC.concat [ filename, " failed (", e, ")" ]
        moveTo (failedDir $ baseDir config) torrent
      Nothing -> do
        BSC.putStrLn $ BSC.concat [ filename, " done" ]
        moveTo (doneDir $ baseDir config) torrent

moveTo :: FilePath -> FilePath -> IO ()
moveTo dir torrent = renameFile torrent (dir </> takeFileName torrent)

check :: FilePath -> IO ()
check dir = do
  baseDirectoryExists <- doesDirectoryExist dir
  unless baseDirectoryExists $ error $ "No such baseDir " ++ dir
  forM_ [failedDir dir, doneDir dir] $ \d -> do
    dirExists <- doesDirectoryExist d
    unless dirExists $ createDirectory d
