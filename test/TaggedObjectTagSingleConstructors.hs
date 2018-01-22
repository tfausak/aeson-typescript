{-# LANGUAGE QuasiQuotes, OverloadedStrings, TemplateHaskell, RecordWildCards, ScopedTypeVariables, NamedFieldPuns #-}

module TaggedObjectTagSingleConstructors (tests) where

import Data.Aeson as A
import Data.Aeson.TH as A
import Data.Aeson.TypeScript.TH
import Data.Monoid
import Data.Proxy
import Data.String.Interpolate.IsString
import Prelude hiding (Double)
import System.IO.Unsafe (unsafePerformIO)
import Test.Hspec
import Test.Tasty
import Test.Tasty.Hspec (testSpec)
import Test.Tasty.Runners
import Util

data Unit = Unit
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''Unit)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''Unit)

data OneFieldRecordless = OneFieldRecordless Int
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''OneFieldRecordless)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''OneFieldRecordless)

data OneField = OneField { simpleString :: String }
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''OneField)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''OneField)

data TwoFieldRecordless = TwoFieldRecordless Int String
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''TwoFieldRecordless)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''TwoFieldRecordless)

data TwoField = TwoField { doubleInt :: Int
                         , doubleString :: String }
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''TwoField)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''TwoField)

data TwoConstructor = Con1 { con1String :: String }
                    | Con2 { con2String :: String
                           , con2Int :: Int }
$(deriveJSON (A.defaultOptions {tagSingleConstructors=True}) ''TwoConstructor)
$(deriveTypeScript (A.defaultOptions {tagSingleConstructors=True}) ''TwoConstructor)


tests = unsafePerformIO $ testSpec "TaggedObject with tagSingleConstructors=True" $ do
  describe "single constructor" $ do
    -- it [i|with a single nullary constructor like #{A.encode Unit}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy Unit)) `shouldBe` "Unit"
    --   (getTypeScriptDeclaration (Proxy :: Proxy Unit)) `shouldBe` ([
    --     TSTypeAlternatives "Unit" [] ["\"Unit\""]
    --     ])

    -- it [i|with a single non-record constructor like #{A.encode $ OneFieldRecordless 42}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy OneFieldRecordless)) `shouldBe` "OneFieldRecordless"
    --   (getTypeScriptDeclaration (Proxy :: Proxy OneFieldRecordless)) `shouldBe` ([
    --     TSTypeAlternatives "OneFieldRecordless" [] ["IOneFieldRecordless"],
    --     TSInterfaceDeclaration "IOneFieldRecordless" [] [TSField False "tag" "\"OneFieldRecordless\"",
    --                                                      TSField False "contents" "number"]
    --     ])

    -- it [i|with a single record constructor like #{A.encode $ OneField "asdf"}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy OneField)) `shouldBe` "OneField"
    --   (getTypeScriptDeclaration (Proxy :: Proxy OneField)) `shouldBe` ([
    --     TSTypeAlternatives "OneField" [] ["IOneField"],
    --     TSInterfaceDeclaration "IOneField" [] [TSField False "tag" "\"OneField\"",
    --                                            TSField False "simpleString" "string"]
    --     ])

    -- it [i|with a two-field non-record constructor like #{A.encode $ TwoFieldRecordless 42 "asdf"}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy TwoFieldRecordless)) `shouldBe` "TwoFieldRecordless"
    --   (getTypeScriptDeclaration (Proxy :: Proxy TwoFieldRecordless)) `shouldBe` ([
    --     TSTypeAlternatives "TwoFieldRecordless" [] ["ITwoFieldRecordless"],
    --     TSInterfaceDeclaration "ITwoFieldRecordless" [] [TSField False "tag" "\"TwoFieldRecordless\"",
    --                                                      TSField False "contents" "[number, string]"]
    --     ])

    -- it [i|with a two-field record constructor like #{A.encode $ TwoField 42 "asdf"}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy TwoField)) `shouldBe` "TwoField"
    --   (getTypeScriptDeclaration (Proxy :: Proxy TwoField)) `shouldBe` ([
    --     TSTypeAlternatives "TwoField" [] ["ITwoField"],
    --     TSInterfaceDeclaration "ITwoField" [] [TSField False "tag" "\"TwoField\"",
    --                                            TSField False "doubleInt" "number",
    --                                            TSField False "doubleString" "string"]
    --     ])

    -- it [i|with a two-constructor type like #{A.encode $ Con1 "asdf"} or #{A.encode $ Con2 "asdf" 42}|] $ do
    --   (getTypeScriptType (Proxy :: Proxy TwoConstructor)) `shouldBe` "TwoConstructor"
    --   (getTypeScriptDeclaration (Proxy :: Proxy TwoConstructor)) `shouldBe` ([
    --     TSTypeAlternatives "TwoConstructor" [] ["ICon1","ICon2"],
    --     TSInterfaceDeclaration "ICon1" [] [TSField False "tag" "\"Con1\"",
    --                                        TSField False "con1String" "string"],
    --     TSInterfaceDeclaration "ICon2" [] [TSField False "tag" "\"Con2\"",
    --                                        TSField False "con2String" "string",
    --                                        TSField False "con2Int" "number"]
    --     ])

    it "type checks everything with tsc" $ do
      let declarations = ((getTypeScriptDeclaration (Proxy :: Proxy Unit)) <>
                          (getTypeScriptDeclaration (Proxy :: Proxy OneFieldRecordless)) <>
                          (getTypeScriptDeclaration (Proxy :: Proxy OneField)) <>
                          (getTypeScriptDeclaration (Proxy :: Proxy TwoFieldRecordless)) <>
                          (getTypeScriptDeclaration (Proxy :: Proxy TwoField)) <>
                          (getTypeScriptDeclaration (Proxy :: Proxy TwoConstructor))
                         )

      let typesAndValues = [(getTypeScriptType (Proxy :: Proxy Unit) , A.encode Unit)
                           , (getTypeScriptType (Proxy :: Proxy OneFieldRecordless) , A.encode $ OneFieldRecordless 42)
                           , (getTypeScriptType (Proxy :: Proxy OneField) , A.encode $ OneField "asdf")
                           , (getTypeScriptType (Proxy :: Proxy TwoFieldRecordless) , A.encode $ TwoFieldRecordless 42 "asdf")
                           , (getTypeScriptType (Proxy :: Proxy TwoField) , A.encode $ TwoField 42 "asdf")
                           , (getTypeScriptType (Proxy :: Proxy TwoConstructor) , A.encode $ Con1 "asdf")
                           , (getTypeScriptType (Proxy :: Proxy TwoConstructor) , A.encode $ Con2 "asdf" 42)
                           ]

      testTypeCheckDeclarations declarations typesAndValues


main = defaultMainWithIngredients defaultIngredients tests
