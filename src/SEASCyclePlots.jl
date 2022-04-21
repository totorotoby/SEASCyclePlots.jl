module SEASCyclePlots

module io

using NCDatasets
using Printf
using DelimitedFiles
using Interpolations
using IterTools

include("conversions.jl")
include("utils.jl")
include("io.jl")

end

module plots

const year_seconds = 31556952
const vars_name = ("δ", "V", "τ", "ψ")

using NCDatasets
using Printf
using DelimitedFiles
using Interpolations
using IterTools
using Makie
using GLMakie

include("plots.jl")

end

end

