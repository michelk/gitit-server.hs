module Main where

import Network.Gitit
import Control.Monad
import Text.XHtml hiding (dir, option, value, header)
import Happstack.Server.SimpleHTTP
import Options.Applicative
import System.Directory
import qualified System.FilePath as F

data CmdArgs = CmdArgs
  {cfgPort :: Int
  ,cfgDir :: String
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
          strOption (long "dir" <> short 'd' <> metavar "DIR" <>
                     help "Directory where wikis are located") <*>
          switch (long "no-listing" <> short 'n' <> help "Whether to not show a directory listing")


configRelDir :: Config -> FilePath -> Config
configRelDir conf path' =
  conf {repositoryPath = path' F.</> repositoryPath conf
       ,staticDir = path' F.</> staticDir conf
       ,templatesDir = path' F.</> templatesDir conf
       ,cacheDir = path' F.</> cacheDir conf
       ,pdfExport = True
       ,pandocUserData = Just (path' F.</> "pandoc")
       ,defaultExtension = "md"
       }


indexPage :: [FilePath] -> Bool -> ServerPart Response
indexPage ds notShowIndex =
  ok $
  toResponse $
  if notShowIndex
     then p << "404 Error"
     else (p << "Wiki index") +++
          ulist << map (\path' -> li << hotlink path' << path') ds


gitit :: Int -> [FilePath] -> Bool-> IO ()
gitit port' ds index =
  do conf <- getDefaultConfig
     forM_ ds $
       \path' ->
         do let conf' = configRelDir conf path'
            createStaticIfMissing conf'
            createRepoIfMissing conf'
            createTemplateIfMissing conf'
            initializeGititState conf'
     simpleHTTP nullConf {port = port' } $
       (nullDir >> indexPage ds index) `mplus` msum (map (wiki . configRelDir conf )  ds)

main :: IO ()
main = do
  cfg <- cmdargs
  let dir' = cfgDir cfg
  ds <- getDirectoryContents dir'
  let ds' = map (dir' F.</> ) . filter ( `notElem` [".", ".."]) $ ds
  ds'' <- filterM doesDirectoryExist ds'
  gitit (cfgPort cfg) ds'' (cfgIndex cfg)
