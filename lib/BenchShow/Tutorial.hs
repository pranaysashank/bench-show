{-# OPTIONS_GHC -fno-warn-unused-imports #-}
-- |
-- Module      : BenchShow.Tutorial
-- Copyright   : (c) 2018 Composewell Technologies
--
-- License     : BSD3
-- Maintainer  : harendra.kumar@gmail.com
--
-- BenchShow generates text reports and graphs from benchmarking results. It
-- allows you to manipulate the format of the report and the benchmarking data
-- to present it in many useful ways.

module BenchShow.Tutorial
    (
    -- * Generating benchmark results
    -- $generating

    -- * Reports and Charts
    -- $plotting

    -- * Grouping
    -- $grouping

    -- * Difference
    -- $difference

    -- * Percentage Difference
    -- $percent

    -- * Statistical Estimators
    -- $estimators

    -- * Difference Strategy
    -- $diffStrategy

    -- * Sorting
    -- $sorting

    -- * Regression
    -- $regression
    )
where

import BenchShow

-- $generating
--
-- To generate benchmark results use @gauge@ or @criterion@ benchmarking
-- libraries, define some benchmarks and run it with @--csv=results.csv@.
--
-- The resulting @results.csv@ may look like the following, for simplicity we
-- have removed some of the fields::
--
-- @
-- Name,time,maxrss
-- vector/fold,6.41620933137583e-4,2879488
-- streamly/fold,6.399582632376517e-4,2879488
-- vector/map,6.388913781259641e-4,2854912
-- streamly/map,6.533649051066093e-4,2793472
-- vector/zip,6.514202653014291e-4,2707456
-- streamly/zip,6.443344209329669e-4,2711552
-- @
--
-- If you run the benchmarks again (maybe after a change) the new results are
-- appended to the file. BenchShow can compare two or more result sets and
-- compare the results in different ways. We will use the above data for the
-- examples below, you can copy it and paste it in a file and use that as input
-- to a BenchShow application.
--
-- @gauge@ supports generating a raw csv file using @--csvraw@ option. The raw
-- csv file has results for many more benchmarking fields other than time e.g.
-- @maxrss@ or @allocated@ and many more.

-- $plotting
--
-- The most common usecase is to see the time and peak memory usage of a
-- program for each benchmark.  The 'report' API with 'Fields' presentation
-- style generates a multi-column report for a quick overview of all
-- benchmarks.  Units of the fields are automatically determined based on the
-- range of values:
--
-- @
-- 'report' "results.csv" Nothing 'defaultConfig' { 'presentation' = 'Fields' }
-- @
--
-- @
-- (default)(Median)
-- Benchmark     time(μs) maxrss(MiB)
-- ------------- -------- -----------
-- vector/fold     641.62        2.75
-- streamly/fold   639.96        2.75
-- vector/map      638.89        2.72
-- streamly/map    653.36        2.66
-- vector/zip      651.42        2.58
-- streamly/zip    644.33        2.59
-- @
--
-- We can generate equivalent visual report using 'graph', it generates one bar
-- chart for each column:
--
-- @
-- 'graph' "results.csv" "output" 'defaultConfig'
-- @
--
-- By default all the benchmarks are placed in a single benchmark group named
-- @default@.
--
-- <<docs/full-median-time.svg Median Time Full>>
--

-- $grouping
--
-- Let's write a benchmark classifier to put the @streamly@ and @vector@
-- benchmarks in their own groups:
--
-- @
--    classifier name =
--        case splitOn "/" name of
--            grp : bench -> Just (grp, concat bench)
--            _          -> Nothing
-- @
--
-- Now we can show the two benchmark groups as columns each showing the time
-- field for that group. We can generate separate reports comparing different
-- benchmark fields (e.g. @time@ and @maxrss@) for all the groups::
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig' { 'classifyBenchmark' = classifier }
-- @
--
-- @
-- (time)(Median)
-- Benchmark streamly(μs) vector(μs)
-- --------- ------------ ----------
-- fold            639.96     641.62
-- map             653.36     638.89
-- zip             644.33     651.42
-- @
--
-- We can do the same graphically as well, just replace 'report' with 'graph'
-- in the code above.  Each group is placed as a cluster on the graph. Multiple
-- clusters are placed side by side on the same scale for easy
-- comparison. For example:
--
-- <<docs/grouped-median-time.svg Median Time Grouped>>

-- $difference
--
-- We can make the first group as baseline and report the subsequent groups as
-- a difference from the baseline:
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'Diff'
--          }
-- @
--
-- @
-- (time)(Median)(Diff using min estimator)
-- Benchmark streamly(μs)(base) vector(μs)(-base)
-- --------- ------------------ -----------------
-- fold                  639.96             +1.66
-- map                   653.36            -14.47
-- zip                   644.33             +7.09
-- @
--
-- In a chart, the second cluster plots the difference @streamly - vector@.
--
-- <<docs/grouped-delta-median-time.svg Median Time Grouped Delta>>

-- $percent
--
-- Absolute difference does not give us a good idea about how good or bad
-- the comparison is. We can report precentage difference instead:
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'PercentDiff'
--          }
-- @
--
-- @
-- (time)(Median)(Diff using min estimator)
-- Benchmark streamly(μs)(base) vector(%)(-base)
-- --------- ------------------ ----------------
-- fold                  639.96            +0.26
-- map                   653.36            -2.22
-- zip                   644.33            +1.10
-- @
--
-- Graphically:
--
-- <<docs/grouped-percent-delta-median-time.svg Median Time Percent Delta>>

-- $estimators
--
-- When multiple samples are available for each benchmark we report the
-- 'Median' by default. However, other estimators like 'Mean' and 'Regression'
-- (a value arrived at by linear regression) can be used:
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'PercentDiff'
--          , 'estimator' = 'Regression'
--          }
-- @
--
-- @
-- (time)(Regression Coeff.)(Diff using min estimator)
-- Benchmark streamly(μs)(base) vector(%)(-base)
-- --------- ------------------ ----------------
-- fold                  639.96            +0.26
-- map                   653.36            -2.22
-- zip                   644.33            +1.10
-- @
--
-- Graphically:
--
-- <<docs/grouped-percent-delta-coeff-time.svg Regression Coeff. Time Percent Delta>>

-- $diffStrategy
--
-- A 'DiffStrategy' controls how the difference between two groups being
-- compared is arrived at. By default we use the 'MinEstimators' strategy which
-- computes the difference using all the available estimators and takes the
-- minimum of all. We can use a 'SingleEstimator' strategy instead if we so
-- desire, it uses the estimatorr configured for the report using the
-- @estimator@ field of the configuration..
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'PercentDiff'
--          , 'estimator' = 'Regression'
--          , 'diffStrategy' = 'SingleEstimator'
--          }
-- @
--
-- @
-- (time)(Regression Coeff.)(Diff )
-- Benchmark streamly(μs)(base) vector(%)(-base)
-- --------- ------------------ ----------------
-- fold                  639.96            +0.26
-- map                   653.36            -2.22
-- zip                   644.33            +1.10
-- @
--
-- Graphically:
--
-- <<docs/grouped-single-estimator-coeff-time.svg Single Estimator Time Percent Delta>>

-- $sorting
--
-- Percentage difference does not immediately tell us the worst affected
-- benchmarks. We can sort the results by the difference:
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'PercentDiff'
--          , 'selectBenchmarks' = \f ->
--                     reverse
--                   $ map fst
--                   $ sortBy (comparing snd)
--                   $ either error id $ f $ 'ColumnIndex' 1
--          }
-- @
--
-- @
-- (time)(Median)(Diff using min estimator)
-- Benchmark streamly(μs)(base) vector(%)(-base)
-- --------- ------------------ ----------------
-- zip                   644.33            +1.10
-- fold                  639.96            +0.26
-- map                   653.36            -2.22
-- @
--
-- This tells us that zip is the relatively worst benchmark for vector compared
-- to streamly, as it takes 1.10% more time, whereas map is the best taking
-- 2.22% less time..
--
-- Graphically:
--
-- <<docs/grouped-percent-delta-sorted-median-time.svg Median Time Percent Delta>>

-- $regression
--
-- We can append benchmarks results from multiple runs to the same file. These
-- runs can then be compared. We can run benchmarks before and after a change
-- and then report the regressions by percentage change in a sorted order:
--
-- Given the following results file with two runs appended:
--
-- @
-- Name,time
-- streamly/fold,1.755309435106302e-2
-- streamly/zip,2.960114434592148e-2
-- streamly/map,2.4673020708256527e-2
-- Name,time
-- streamly/fold,8.970816964261911e-3
-- streamly/zip,8.439519884529081e-3
-- streamly/map,6.972814233286865e-3
-- @
--
-- This code generates the report that follows:
--
-- @
--    'report' "results.csv" Nothing
--      'defaultConfig'
--          { 'classifyBenchmark' = classifier
--          , 'presentation' = 'Groups' 'PercentDiff'
--          , 'selectBenchmarks' = \f ->
--                     reverse
--                   $ map fst
--                   $ sortBy (comparing snd)
--                   $ either error id $ f $ 'ColumnIndex' 1
--          }
-- @
--
-- @
-- (time)(Median)(Diff using min estimator)
-- Benchmark streamly(0)(μs)(base) streamly(1)(%)(-base)
-- --------- --------------------- ---------------------
-- zip                      644.33                +23.28
-- map                      653.36                 +7.65
-- fold                     639.96                -15.63
-- @
--
-- It tells us that in the second run the worst affected benchmark is zip
-- taking 23.28 percent more time comapred to the baseline.
--
-- Graphically:
--
-- <<docs/regression-percent-descending-median-time.svg Median Time Regression>>
