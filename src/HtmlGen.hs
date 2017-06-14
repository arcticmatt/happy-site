{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

module HtmlGen where

import Lucid.Base
import Lucid.Html5
import Data.Monoid ((<>))
import Data.Text (Text)
import Data.Functor.Identity (Identity)

render :: [HtmlT Identity ()] -> Html ()
render xs = html_ $ do
  head_ $ do
    title_ "Happy page"
    link_ [rel_ "stylesheet", type_ "text/css", href_ "css/screen.css"]
  body_ [id_ "mybody", onload_ "ran_col()", width_ "100%", style_ "font-family:Bookman Old Style;"]
    $ script_ [src_ "color-script.js"] ""
      <> (term "center" [class_ "container"] $ mconcat $ fmap h1_ xs)
      <> (div_ [style_ "position: absolute; bottom: 20px; right: 30px; text-align:left"]
         $ a_ [href_ "https://github.com/arcticmatt/happy-site"] "view source")
