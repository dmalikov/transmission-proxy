import           Config
import           Proxy

main :: IO ()
main = startServing =<< readConfig
