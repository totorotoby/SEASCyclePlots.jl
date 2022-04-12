module SEASCyclePlots

using NCDatasets
using Printf
using DelimitedFiles
using GLMakie
using Interpolations

const year_seconds = 31556952

include("conversions.jl")
include("utils.jl")
include("io.jl")
include("plots.jl")

end
