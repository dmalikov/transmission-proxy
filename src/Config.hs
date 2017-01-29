{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
module Config
  ( readConfig
  , Config(..), Credentials(..), TransmissionConfig(..)
  ) where

import           Control.Monad
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy.Char8 as BSC
import           Data.Map
import           System.Directory           (doesFileExist, getHomeDirectory)
import           System.FilePath            ((</>))


-- | Configuration
data Config = Config
  { baseDir      :: FilePath -- directory with torrents that transmission-proxy will serve
  , transmission :: TransmissionConfig -- transmission configuration
  } deriving (Eq, Show)

-- | Some transmission-remote arguments
data TransmissionConfig = TransmissionConfig
  { host              :: String -- IP or hostname of a server where transmission-remote works
  , downloadDirPrefix :: FilePath -- first part of `--download-dir` argument, second is based on the torrent tracker
  , trackers          :: Map String String -- mapping from a tracker name to a directory name
  , auth              :: Maybe Credentials -- credential used for transmission-remote session
  } deriving (Eq, Show)

data Credentials = Credentials
  { username :: String
  , password :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''Config)
$(deriveJSON defaultOptions ''TransmissionConfig)
$(deriveJSON defaultOptions ''Credentials)

readConfig :: IO Config
readConfig = do
  configFilePath <- (</> ".transmission.proxy.rc") <$> getHomeDirectory
  doesFileExist configFilePath >>= \exist -> unless exist $ error $ configFilePath ++ ": No such file"
  decode <$> BSC.readFile configFilePath >>= \case
    Just config -> return config
    Nothing -> error $ "Error: cannot parse config file " ++ configFilePath
