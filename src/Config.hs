{-# Language DeriveAnyClass #-}
{-# Language DeriveGeneric #-}
module Config
  ( readConfig
  , Config(..), Credentials(..), TransmissionConfig(..)
  ) where

import           Data.Aeson
import           Data.HashMap.Strict (HashMap)
import           GHC.Generics
import           System.Directory (getHomeDirectory)
import           System.FilePath ((</>))
import           System.Exit (die)


-- | Configuration
data Config = Config
  { baseDir      :: FilePath -- directory with torrents that transmission-proxy will serve
  , transmission :: TransmissionConfig -- transmission configuration
  } deriving (Eq, Show, Generic, FromJSON, ToJSON)

-- | Some transmission-remote arguments
data TransmissionConfig = TransmissionConfig
  { host              :: String -- IP or hostname of a server where transmission-remote works
  , downloadDirPrefix :: FilePath -- first part of `--download-dir` argument, second is based on the torrent tracker
  , trackers          :: HashMap String String -- mapping from a tracker name to a directory name
  , auth              :: Maybe Credentials -- credential used for transmission-remote session
  } deriving (Eq, Show, Generic, FromJSON, ToJSON)

data Credentials = Credentials
  { username :: String
  , password :: String
  } deriving (Eq, Show, Generic, FromJSON, ToJSON)

readConfig :: IO Config
readConfig = do
  configFilePath <- (</> ".transmission.proxy.rc") <$> getHomeDirectory
  dieOnLeft $ eitherDecodeFileStrict configFilePath

dieOnLeft :: IO (Either String r) -> IO r
dieOnLeft m = do
  v <- m
  case v of
    Left e -> die e
    Right r -> pure r
