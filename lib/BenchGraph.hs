-- |
-- Module      : BenchGraph
-- Copyright   : (c) 2017 Composewell Technologies
--
-- License     : BSD3
-- Maintainer  : harendra.kumar@gmail.com
-- Stability   : experimental
-- Portability : GHC
--
-- BenchGraph provides a DSL to quickly generate visual graphs or textual
-- reports from benchmarking results (CSV) produced by @gauge@ or @criterion@.
-- Reports or graphs can be formatted in many useful ways. For example, we can
-- prepare a graphical bar chart or column wise textual report comparing the
-- performance of two packages or comparing the performance regression in a
-- package caused by a particular change. Absolute or percentage difference
-- between sets of benchmarks can be presented and sorted based on the
-- difference. This allows us to easily identify the worst affected benchmarks
-- and fix them. The presentation is quite flexible and a lot more interesting
-- things can be done with it.
--
-- = How it works
--
-- The input is the CSV file generated by @gauge --csv=results.csv@ or a
-- similar output generated by @criterion@. You need to invoke the 'graphCmp'
-- function with an appropriate 'Config' to control various parameters of graph
-- or report generation.  In most cases 'defaultConfig' should just do the job
-- and no config is required.
--
-- For advanced use, benchmark results found in the CSV file can be classified
-- into several groups using a classifier function and each group is displayed
-- side by side in the graph on the same scale for comparison.  The constituent
-- benchmarks in each benchmark group are placed together as a group and a
-- legend is displayed to mark who is who.
--
-- In a raw benchmark file we may have data for multiple iterations of each
-- benchmark. BenchGraph combines results of all iterations depending on the
-- field type. For example if the field is "time" it takes the mean of all
-- iterations and if the field is "maxrss" it takes the maximum of all
-- iterations.
--
-- = Types of charts or reports
--
-- There are two main ways of presenting charts or reports. In a
-- non-comparative presentation we present one report or chart per result set
-- in the input file. Each report is for one benchmark group and may contain
-- one or more benchmarking fields as columns showing the values of those
-- fields for each benchmark row.
-- In a comparative presentation, we present one report or chart per
-- benchmarking field in the input file. Each report is for one benchmark field
-- and may contain two or more benchmark groups as the columns showing the
-- values of the chosen field for each benchmark row.
-- See the tutorial module for examples of each format.
--
-- = Tutorial and Examples
--
-- See the tutorial module "BenchGraph.Tutorial" for sample charts and a
-- comprehensive guide to generating reports and graphs.  See the @test@
-- directory for many usage examples, run the tests to see the charts generated
-- by these tests.

module BenchGraph
    ( ComparisonStyle(..)
    , Granularity (..)
    , SortField (..)
    , Config(..)
    , defaultConfig
    , graphCmp
    , bgraph
    ) where

import BenchGraph.Common
import BenchGraph.Graph
