-- |
-- Module      : BenchShow
-- Copyright   : (c) 2017 Composewell Technologies
--
-- License     : BSD3
-- Maintainer  : harendra.kumar@gmail.com
-- Stability   : experimental
-- Portability : GHC
--
-- BenchShow provides a DSL to quickly generate visual graphs or textual
-- reports from benchmarking results file (CSV) produced by @gauge@ or
-- @criterion@.  Reports or graphs can be formatted and presented in many
-- useful ways. For example, we can prepare a graphical bar chart or column
-- wise textual report comparing the performance of two packages or comparing
-- the performance regression in a package caused by a particular change.
-- Absolute or percentage difference between sets of benchmarks can be
-- presented and sorted based on the difference. This
-- allows us to easily identify the worst affected benchmarks and fix them. The
-- presentation is quite flexible and a lot more interesting things can be done
-- with it.
--
-- = Generating Graphs and Reports
--
-- The input is a CSV file generated by @gauge --csv=results.csv@ or a similar
-- output generated by @criterion@. The 'graph' or the 'report' function is
-- invoked on the file with an appropriate 'Config' to control various
-- parameters of graph or report generation.  In most cases 'defaultConfig'
-- should just do the job and a specific config may not be required.
--
-- = Fields, Groups and RunIds
--
-- In the documentation when we say @field@ it means a benchmarking field e.g.
-- @time@ or @maxrss@. When we say @group@ it means a group of benchmarks. An
-- input file may have benchmark results collected from multiple runs.  By
-- default each run is designated as a single benchmark group with the group
-- name @default@. Benchmark groups from different runs are distinguished
-- using a @runId@ which is the index of the run in the file, starting with 0.
--
-- Benchmarks can be classified into multiple groups using 'classifyBenchmark'.
-- Benchmarks from each run can be divided into multiple groups. In a multi-run
-- input benchmark groups can be fully specified using the groupname (either
-- @default@ or as classified by 'classifyBenchmark') and the
-- runId.
--
-- = Presentation
--
-- We can present the results in a textual format using 'report' or as a
-- graphical chart using 'graph'. Each report consists of a number of
-- benchmarks as rows and the columns can either be benchmarking fields or
-- groups of benchmarks depending on the 'Presentation' setting. In a graphical
-- chart, we present multiple clusters, each cluster representing one column
-- from the textual report, the rows (i.e.  the benchmarks) are represented as
-- bars in the cluster.
--
-- When the columns are groups, each report consists of results for a single
-- benchmarking field for different benchmark groups.  Using 'GroupStyle', we
-- can further specify how we want to present the results the groups. We can
-- either present absolute values of the field for each group or we can make
-- the first group as a baseline and present differences from the baseline for
-- the subsequent groups.
--
-- When the columns are fields, each report consists of results for a single
-- benchmarking group. Fields cannot be compared like groups because they are
-- of different types and have different measurement units.
--
-- The units in the report are automatically determined based on the minimum
-- value in the range of values present. The ranges for fields can be
-- overridden using 'fieldRanges'.
--
-- = Mean and Max
--
-- In a raw benchmark file (@--csvraw=results.csv@ with @gauge@) we may have
-- data for multiple iterations of each benchmark. BenchShow combines results
-- of all iterations depending on the field type. For example if the field is
-- @time@ it takes the mean of all iterations and if the field is @maxrss@ it
-- takes the maximum of all iterations.
--
-- = Tutorial and Examples
--
-- See the tutorial module "BenchShow.Tutorial" for sample charts and a
-- comprehensive guide to generating reports and graphs.  See the @test@
-- directory for many usage examples, run the tests to see the charts generated
-- by these tests.

module BenchShow
    ( GroupStyle(..)
    , Presentation(..)
    , Estimator (..)
    , DiffStrategy (..)
    , SortColumn (..)
    , FieldTick (..)
    , Config(..)
    , defaultConfig
    , graph
    , report
    ) where

import BenchShow.Common
import BenchShow.Graph
import BenchShow.Report