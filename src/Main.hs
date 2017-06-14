{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty as W
import qualified HtmlGen as H
import Lucid.Base as L
import SqlTable (getRandItem)
import qualified SqlTable as S
import Control.Monad.IO.Class
import Database.SQLite.Simple
import Data.Maybe (fromJust)
import Network.Wai.Middleware.Static
import System.Environment
import Control.Monad (liftM)

numItems :: Int
numItems = 3

lucid :: Html () -> ActionM ()
lucid = W.html . L.renderText

main :: IO ()
main = do
  port <- liftM read $ getEnv "PORT"
  scotty port $ do
    middleware $ staticPolicy (noDots >-> addBase "static")
    get "/" $ do
      conn <- liftIO $ open S.tblname
      items <- liftIO $ S.getRandItems conn 3
      let contents = fmap (L.toHtml . S.content . fromJust) items
      lucid $ H.render contents
