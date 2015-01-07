import           Config
import           Servant

main :: IO ()
main = startServing =<< readConfig
