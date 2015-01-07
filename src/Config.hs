{-# LANGUAGE OverloadedStrings #-}
module Config
  ( readConfig
  , Config(..)
  , TransmissionConfig(..)
  ) where

import           Control.Applicative
import           Control.Monad
import           Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BSC
import           Data.Map
import           System.Directory           (getHomeDirectory)
import           System.FilePath            ((</>))


-- | Servant configuration
data Config = Config
  { _baseDir            :: FilePath -- directory with torrents servant will serve
  , _transmissionConfig :: TransmissionConfig -- transmission configuration
  } deriving Show

-- | Some transmission-remote arguments
data TransmissionConfig = TransmissionConfig
  { _host              :: String -- IP or hostname of a server where transmission-remote works
  , _downloadDirPrefix :: FilePath -- first part of `--download-dir` argument, second is based on the torrent tracker
  , _trackers          :: Map String String -- mapping from a tracker name to a directory name
  } deriving Show

instance FromJSON Config where
  parseJSON (Object v) = Config <$>
    v .: "baseDir" <*>
    v .: "transmission"
  parseJSON _ = mzero

instance FromJSON TransmissionConfig where
  parseJSON (Object v) = TransmissionConfig <$>
    v .: "host" <*>
    v .: "downloadDirPrefix" <*>
    v .: "trackers"
  parseJSON _ = mzero

readConfig :: IO Config
readConfig = do
  hd <- getHomeDirectory
  maybeConfig <- decode <$> BSC.readFile (hd </> ".servantrc")
  case maybeConfig of
    Just config -> return config
    Nothing -> error "Error: cannot find a config file ~/.servantrc"

