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
  body_ [id_ "mybody", onload_ "ran_col()", class_ "container", width_ "100%", style_ "font-family:Bookman Old Style;"]
    $ script_ [src_ "color-script.js"] "" <>
      (term "center" $ mconcat $ fmap h1_ xs)
