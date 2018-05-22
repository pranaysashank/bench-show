{-# LANGUAGE FlexibleContexts #-}

module Main where

import Data.List.Split (splitOn)
-- import Data.Maybe (catMaybes)
-- import System.Process.Typed (readProcess_)
import BenchGraph (bgraph, defaultConfig, Config(..), ComparisonStyle(..))

import Data.List

-- import qualified Data.Text.Lazy as T
-- import qualified Data.Text.Lazy.Encoding as T

-- XXX use package name and a tag
packages :: [String]
packages =
    [ "list"
    , "pure-vector"
    , "vector"
    , "streamly"
    , "streaming"
    , "conduit"
    , "pipes"
    , "machines"
    , "drinkery"
    ]

-------------------------------------------------------------------------------
main :: IO ()
main = do
    {-
    (out, _) <- readProcess_ "stack --system-ghc list-dependencies --bench"

    -- Get our streaming packages and their versions
    let match [] = Nothing
        match (_ : []) = Nothing
        match (x : y : _) =
            case elem x packages of
                False -> Nothing
                True -> Just (x, y)

        -- pkginfo is [(packagename, version)]
        pkginfo =
              catMaybes
            $ map match
            $ map words (lines (T.unpack $ T.decodeUtf8 out))
    -}
    let pkginfo = []

    -- suffix versions to packages
    let suffixVersion p =
            case lookup p pkginfo of
                Nothing -> p
                Just v -> p ++ "-" ++ v

    let title = "Cheaper Operations (Lower is Better)"
        prefixes =
            [ "elimination/toNull"
            , "filtering/drop-all"
            , "filtering/dropWhile-true"
            , "filtering/filter-all-out"
            , "elimination/last"
            , "elimination/fold"
            , "transformation/map"
            , "filtering/take-all"
            , "filtering/takeWhile-true"
            , "filtering/filter-all-in"
            , "filtering/filter-even"
            , "transformation/scan"
            ]
        cfg = defaultConfig
            { chartTitle = Just title
            , outputDir = "charts"
            , classifyBenchmark = \bm ->
                case any (`isPrefixOf` bm) prefixes of
                    True ->
                        let xs = reverse (splitOn "/" bm)
                        in Just (suffixVersion (xs !! 0), xs !! 1)
                    False -> Nothing
            , sortBenchmarks = \bs ->
                let i = intersect (map (last . splitOn "/") prefixes) bs
                in i ++ (bs \\ i)
            , sortBenchGroups = \gs ->
                let i = intersect (map suffixVersion packages) gs
                in i ++ (gs \\ i)
            }

    bgraph "test/results.csv" "csv-mean-full" "mean" cfg
    bgraph "test/results.csvraw" "csvraw-time-full" "time" cfg
    bgraph "test/results.csvraw" "csvraw-time-delta" "time"
            (cfg {setYScale = Just (-20000, 50000,7)
                 , comparisonStyle = CompareDelta
                 })

    bgraph "test/results.csvraw" "csvraw-allocated-full" "allocated" cfg
    bgraph "test/results.csvraw" "csvraw-bytescopied-full" "bytesCopied" cfg
    bgraph "test/results.csvraw" "csvraw-mutatorWallSeconds-full" "mutatorWallSeconds" cfg
    bgraph "test/results.csvraw" "csvraw-mutatorCpuSeconds-full" "mutatorCpuSeconds" cfg
    bgraph "test/results.csvraw" "csvraw-gcWallSeconds-full" "gcWallSeconds" cfg
    bgraph "test/results.csvraw" "csvraw-gcCpuSeconds-full" "gcCpuSeconds" cfg
    bgraph "test/results.csvraw" "csvraw-cycles-full" "cycles" cfg
