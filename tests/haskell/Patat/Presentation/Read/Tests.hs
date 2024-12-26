{-# LANGUAGE OverloadedStrings #-}
module Patat.Presentation.Read.Tests
    ( tests
    ) where


--------------------------------------------------------------------------------
import           Patat.Presentation.Read
import           Patat.Presentation.Syntax
import qualified Test.Tasty                as Tasty
import qualified Test.Tasty.HUnit          as Tasty
import qualified Text.Pandoc               as Pandoc


--------------------------------------------------------------------------------
tests :: Tasty.TestTree
tests = Tasty.testGroup "Patat.Presentation.Read.Tests"
    [ testReadMetaSettings
    , testDetectSlideLevel
    ]


--------------------------------------------------------------------------------
testReadMetaSettings :: Tasty.TestTree
testReadMetaSettings = Tasty.testCase "readMetaSettings" $
        case readMetaSettings invalidMetadata of
            Left _  -> pure ()
            Right _ -> Tasty.assertFailure "expecting invalid metadata"
  where
    invalidMetadata =
        "---\n\
        \title: mixing tabs and spaces bad\n\
        \author: thoastbrot\n\
        \patat:\n\
        \    images:\n\
        \            backend: 'w3m'\n\
        \            path: '/usr/lib/w3m/w3mimgdisplay'\n\
        \    theme:\n\
        \\theader: [vividBlue,onDullBlack]\n\
        \        emph: [dullBlue,italic]\n\
        \...\n\
        \\n\
        \Hi!"


--------------------------------------------------------------------------------
testDetectSlideLevel :: Tasty.TestTree
testDetectSlideLevel = Tasty.testGroup "detectSlideLevel"
    [ Tasty.testCase "01" $
        (Tasty.@=?) 1 $ detectSlideLevel
            [ Header 1 mempty [Pandoc.Str "Intro"]
            , Para [Pandoc.Str "Hi"]
            ]
    , Tasty.testCase "02" $
        (Tasty.@=?) 2 $ detectSlideLevel
            [ Header 1 mempty [Pandoc.Str "Intro"]
            , Header 2 mempty [Pandoc.Str "Detail"]
            , Para [Pandoc.Str "Hi"]
            ]
    , Tasty.testCase "03" $
        (Tasty.@=?) 2 $ detectSlideLevel
            [ Header 1 mempty [Pandoc.Str "Intro"]
            , RawBlock "html" "<!-- Some speaker notes -->"
            , Header 2 mempty [Pandoc.Str "Detail"]
            , Para [Pandoc.Str "Hi"]
            ]
    ]
