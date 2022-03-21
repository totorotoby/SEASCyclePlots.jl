using SEASCyclePlots
using Documenter

DocMeta.setdocmeta!(SEASCyclePlots, :DocTestSetup, :(using SEASCyclePlots); recursive=true)

makedocs(;
    modules=[SEASCyclePlots],
    authors="Toby Harvey <tharvey2@uoregon.edu> and contributors",
    repo="https://github.com/totorotoby/SEASCyclePlots.jl/blob/{commit}{path}#{line}",
    sitename="SEASCyclePlots.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://totorotoby.github.io/SEASCyclePlots.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/totorotoby/SEASCyclePlots.jl",
    devbranch="main",
)
