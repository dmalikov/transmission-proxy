{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
module Proxy (startServing) where

import           Control.Concurrent    (threadDelay)
import           Control.Monad
import qualified Data.ByteString.Char8 as BSC
import           Prelude               hiding (and)
import           System.Directory
import           System.FilePath
import           System.FilePath.Find
import           System.FSNotify
import           System.Log.FastLogger hiding (check)

import           Config
import           Transmission

-- | Check given directory for unserved torrents and start watching it
startServing :: Config -> IO ()
startServing config = do
  check $ baseDir config
  loggerSet <- newStdoutLoggerSet 1
  torrents <- find (depth ==? 0) (fileType ==? RegularFile &&? extension ==? ".torrent") $ baseDir config
  pushLogStrLn loggerSet (toLogStr ("Found " ++ show (length torrents) ++ " torrents"))
  forM_ torrents $ serve loggerSet config
  withManagerConf WatchConfig { confDebounce     = Debounce 1000
                              , confUsePolling   = False
                              , confPollInterval = 1 -- doesn't matter
                              }
                  $ \mgr -> do
    _ <- watchDir
      mgr
      (baseDir config)
      (isAdded `and` isTorrent)
      (\event -> do
        pushLogStrLn loggerSet (toLogStr (show event))
        serve loggerSet config $ eventPath event)
    forever $ threadDelay 1000000

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

serve :: LoggerSet -> Config -> FilePath -> IO ()
serve loggerSet config torrent = do
  let filename = takeFileName torrent
  send (transmission config) torrent >>= \case
    Just e -> do
      pushLogStrLn loggerSet (toLogStr (filename ++ " failed (" ++ BSC.unpack e ++ ")"))
      moveTo (failedDir $ baseDir config) torrent
    Nothing -> do
      pushLogStrLn loggerSet (toLogStr (filename ++ " done"))
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
