{-# LANGUAGE CPP, QuasiQuotes, OverloadedStrings, TemplateHaskell, RecordWildCards, ScopedTypeVariables, NamedFieldPuns #-}

module Untagged (tests) where

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

-- Between Aeson 0.11.3.0 and 1.0.0.0, UntaggedValue was added
-- Disable these tests if it's not present
#if MIN_VERSION_aeson(1,0,0)
data Unit = Unit
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''Unit)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''Unit)

data OneFieldRecordless = OneFieldRecordless Int
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''OneFieldRecordless)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''OneFieldRecordless)

data OneField = OneField { simpleString :: String }
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''OneField)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''OneField)

data TwoFieldRecordless = TwoFieldRecordless Int String
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoFieldRecordless)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoFieldRecordless)

data TwoField = TwoField { doubleInt :: Int
                         , doubleString :: String }
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoField)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoField)

data TwoConstructor = Con1 { con1String :: String }
                    | Con2 { con2String :: String
                           , con2Int :: Int }
$(deriveJSON (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoConstructor)
$(deriveTypeScript (A.defaultOptions {sumEncoding=UntaggedValue}) ''TwoConstructor)

data MixedNullary = Normal
                  | Other String deriving (Eq, Ord, Show)
$(deriveJSON (A.defaultOptions { sumEncoding=UntaggedValue }) ''MixedNullary)
$(deriveTypeScript (A.defaultOptions { sumEncoding=UntaggedValue }) ''MixedNullary)

declarations = ((getTypeScriptDeclaration (Proxy :: Proxy Unit)) <>
                 (getTypeScriptDeclaration (Proxy :: Proxy OneFieldRecordless)) <>
                 (getTypeScriptDeclaration (Proxy :: Proxy OneField)) <>
                 (getTypeScriptDeclaration (Proxy :: Proxy TwoFieldRecordless)) <>
                 (getTypeScriptDeclaration (Proxy :: Proxy TwoField)) <>
                 (getTypeScriptDeclaration (Proxy :: Proxy TwoConstructor))
               )

typesAndValues = [(getTypeScriptType (Proxy :: Proxy Unit) , A.encode Unit)
                 , (getTypeScriptType (Proxy :: Proxy OneFieldRecordless) , A.encode $ OneFieldRecordless 42)
                 , (getTypeScriptType (Proxy :: Proxy OneField) , A.encode $ OneField "asdf")
                 , (getTypeScriptType (Proxy :: Proxy TwoFieldRecordless) , A.encode $ TwoFieldRecordless 42 "asdf")
                 , (getTypeScriptType (Proxy :: Proxy TwoField) , A.encode $ TwoField 42 "asdf")
                 , (getTypeScriptType (Proxy :: Proxy TwoConstructor) , A.encode $ Con1 "asdf")
                 , (getTypeScriptType (Proxy :: Proxy TwoConstructor) , A.encode $ Con2 "asdf" 42)
                 ]

tests = unsafePerformIO $ testSpec "UntaggedValue" $ do
  it "generates the right output" $ do
    let file = getTSFile declarations typesAndValues
    file `shouldBe` [i|
type Unit = IUnit;

type IUnit = void[];

type OneFieldRecordless = IOneFieldRecordless;

type IOneFieldRecordless = number;

type OneField = IOneField;

interface IOneField {
  simpleString: string;
}

type TwoFieldRecordless = ITwoFieldRecordless;

type ITwoFieldRecordless = [number, string];

type TwoField = ITwoField;

interface ITwoField {
  doubleInt: number;
  doubleString: string;
}

type TwoConstructor = ICon1 | ICon2;

interface ICon1 {
  con1String: string;
}

interface ICon2 {
  con2String: string;
  con2Int: number;
}

let x1: Unit = [];
let x2: OneFieldRecordless = 42;
let x3: OneField = {\"simpleString\":\"asdf\"};
let x4: TwoFieldRecordless = [42,\"asdf\"];
let x5: TwoField = {\"doubleInt\":42,\"doubleString\":\"asdf\"};
let x6: TwoConstructor = {\"con1String\":\"asdf\"};
let x7: TwoConstructor = {\"con2String\":\"asdf\",\"con2Int\":42};

|]

  it "type checks everything with tsc" $ do
    testTypeCheckDeclarations declarations typesAndValues
#else
tests = unsafePerformIO $ testSpec "UntaggedValue" $ do
  it "tests are disabled for this Aeson version" $ do
    2 `shouldBe` 2
#endif

main = defaultMainWithIngredients defaultIngredients tests
