--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           GHC.IO.Encoding

--------------------------------------------------------------------------------
main :: IO ()
main = 
    let config = defaultConfiguration in
    hakyllWith (defaultConfiguration {destinationDirectory = "docs"}) $ do
        match "images/*" $ do
            route   idRoute
            compile copyFileCompiler
    
        match "css/*" $ do
            route   idRoute
            compile compressCssCompiler
    
        match (fromList ["about.rst", "contact.markdown"]) $ do
            route   $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls
        match "csl/*" $ compile cslCompiler
        match "bib/*" $ compile biblioCompiler
        match "posts/*" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= (\i -> do
                    mBib <- getMetadataField (itemIdentifier i) "bib"
                    case mBib of
                        (Just bib) -> pandocBiblioCompiler "csl/elsevier-with-titles-alphabetical.csl" bib
                        Nothing -> return i)
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls
    
        create ["archive.html"] $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let archiveCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Archives"            `mappend`
                        defaultContext
    
                makeItem ""
                    >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                    >>= relativizeUrls
    
    
        match "index.html" $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                postBody <- loadSnapshot (itemIdentifier $ head posts) "content"                              
                let indexCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "post" (itemBody postBody)    `mappend`
                        constField "title" "Home"                `mappend`
                        defaultContext                
                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/recentPost.html" indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" indexCtx
                    >>= relativizeUrls
    
        match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

