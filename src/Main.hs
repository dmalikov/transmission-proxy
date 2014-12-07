import qualified Data.Map as Map

import           Config
import           Servant

main :: IO ()
main = startServing $
  Config "/home/m/downloads/torrents/" $
  TransmissionConfig "192.168.1.43" "/volume1/homes/transmission/" $ Map.fromList
    [ ("please.passthepopcorn.me", "ptp")
    , ("tracker.broadcasthe.net", "btn")
    , ("tracker.what.cd", "whatcome")
    , ("mutracker.org", "outcome")
    , ("x264.me", "x264")
    ]
