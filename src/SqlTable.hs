{-# LANGUAGE QuasiQuotes, OverloadedStrings #-}
-- Here, we will dump the data contained in happythings_form.txt into
-- a sqlite database.

module SqlTable where

import Control.Exception
import Data.Typeable
import Text.RawString.QQ
import Database.SQLite.Simple
import Database.SQLite.Simple.Types
import Data.Text (Text)
-- import qualified Data.Text as T
import Control.Monad (forM_, forM)
import Data.String.Utils (strip)
import Data.Char (isControl)
-- import Debug.Trace (trace)
import System.Random

fname :: String
fname = "happythings_form.txt"

tblname :: String
tblname = "happy.db"

data Item =
  Item {
      itemId :: Integer
    , content :: Text
  }

instance Show Item where
  show (Item id_ content_) = unwords ["Item", show id_, show content_]

data DuplicateData =
  DuplicateData
  deriving (Eq, Show, Typeable)

instance Exception DuplicateData

instance FromRow Item where
  fromRow = Item <$> field <*> field

instance ToRow Item where
  toRow (Item id_ content_) = toRow (id_, content_)

insertItemQ :: Query
insertItemQ = "INSERT INTO items VALUES (?, ?)"

getItemQ :: Query
getItemQ = "SELECT * FROM items WHERE id = ?"

createItems :: Query
createItems = [r|
CREATE TABLE IF NOT EXISTS items
  (id INTEGER PRIMARY KEY AUTOINCREMENT,
   content TEXT UNIQUE)
|]

-- Note: opens and closes connection within
createDatabase :: IO ()
createDatabase = do
  conn <- open tblname
  execute_ conn createItems
  close conn

-- Note: opens and closes connection within
fillDatabase :: IO ()
fillDatabase = do
  conn <- open tblname
  content_ <- readFile fname
  let happyLines = lines content_
      happyTups  = map ((,) Null . stripS) happyLines
  forM_ happyTups (execute conn insertItemQ)
  close conn

getCount :: Connection -> IO Integer
getCount conn = do
  [[c]] <- query_ conn "SELECT COUNT(*) FROM items"
  return c

getItem :: Connection -> Integer -> IO (Maybe Item)
getItem conn id_ = do
  results <- query conn getItemQ (Only id_)
  case results of
    [] -> return Nothing
    [item] -> return $ Just item
    _ -> throwIO DuplicateData -- we don't catch this

getRandItem :: Connection -> IO (Maybe Item)
getRandItem conn = do
  count <- getCount conn
  randRow <- randomRIO (1, count)
  getItem conn randRow

getRandItems :: Connection -> Int -> IO [Maybe Item]
getRandItems conn n = forM [1..n] (const $ getRandItem conn)

-- Inefficient, but doesn't matter
stripS :: String -> String
stripS = takeWhile (not . isControl) . dropWhile isControl . strip
