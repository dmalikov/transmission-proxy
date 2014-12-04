module Config
  ( Config(..)
  , TransmissionConfig(..)
  ) where

import Data.Map

-- | Servant configuration
data Config = Config
  { _baseDir :: FilePath -- directory with torrents servant will serve
  , _transmissionConfig :: TransmissionConfig -- transmission configuration
  }

-- | Some transmission-remote arguments
data TransmissionConfig = TransmissionConfig
  { _host :: String -- IP or hostname of a server where transmission-remote works
  , _downloadDirPrefix :: FilePath -- first part of `--download-dir` argument, second is based on the torrent tracker
  , _trackers :: Map String String -- mapping from a tracker name to a directory name
  }
