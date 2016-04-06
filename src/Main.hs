module Main where

import Network.Gitit
import Control.Monad
import Text.XHtml hiding (dir, option, value, header)
import Happstack.Server.SimpleHTTP
import Options.Applicative
import System.Directory
import qualified System.FilePath as F
import Data.List.Split (splitOn)

data CmdArgs = CmdArgs
  {cfgPort :: Int
  ,cfgWikis :: String
  ,cfgIndex :: Bool }


cmdargs :: IO CmdArgs
cmdargs = execParser opts
  where opts =
          info (helper <*> cmdargsP)
               (fullDesc <>
                progDesc "Run multiple gitit-wikis under a common directory" <>
                header "gitit-server - Program to run multiple gitit-wikis under a common directory")
        cmdargsP =
          CmdArgs <$>
          option auto
                 (long "port" <> short 'p' <> metavar "PORT" <>
                  help "Port to listen") <*>
          strOption (long "wikis" <> short 'w' <> metavar "LIST" <>
                     help "Repository-directories of wikis to take into account (eg: uno:due:tre)") <*>
          switch (long "no-listing" <> short 'n' <> help "Whether to not show a directory listing")


customizeConfig :: Config -> Config
customizeConfig conf =
  conf {pdfExport = True
       ,defaultExtension = "md"}


configRelDir :: Config -> FilePath -> Config
configRelDir conf path' =
  conf {repositoryPath = path'
       ,pdfExport = True
       ,defaultExtension = "md"
       }

indexPage :: [FilePath] -> Bool -> ServerPart Response
indexPage ds notShowIndex =
  ok $
  toResponse $
  if notShowIndex
     then p << ""
     else (p << "Wiki index") +++
          ulist << map (\path' -> li << hotlink path' << path') ds

handlerFor :: Config -> FilePath-> ServerPart Response
handlerFor conf path' = dir path' $
  wiki conf{ repositoryPath = path'}

gitit :: Int -> [FilePath] -> Bool-> IO ()
gitit port' ds index =
  do conf <- getDefaultConfig
     let conf' = customizeConfig conf
     forM_ ds $
       \path' ->
         do let conf'' = conf' {repositoryPath = path'}
            createRepoIfMissing conf''
     createStaticIfMissing conf'
     createTemplateIfMissing conf'
     initializeGititState conf'
     simpleHTTP nullConf {port = port' } $
       (nullDir >> (indexPage ds index)) `mplus` msum (map (handlerFor conf') ds)

main :: IO ()
main = do
  cfg <- cmdargs
  let ds = splitOn ":" (cfgWikis cfg)
  gitit (cfgPort cfg) ds (cfgIndex cfg)
