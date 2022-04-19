module SEASCyclePlots

using NCDatasets
using Printf
using DelimitedFiles
using GLMakie
using Makie
using Interpolations
using IterTools

const year_seconds = 31556952
const vars_name = ("δ", "V", "τ", "ψ")

include("conversions.jl")
include("utils.jl")
include("io.jl")
include("plots.jl")

end
