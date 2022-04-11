export init_fault_data, init_station_data


"""
    function init_fault_data(filename::String)

    creates a NetCDF file called filename in which fault time series data is stored.

"""
function init_fault_data(filename::String, var::String, nn::Int)

    ds = NCDataset(filename, "c")
    
    defDim(ds, "cycle", Inf)
    defDim(ds, "phase", 2)
    defDim(ds, "time index", Inf)
    defDim(ds, "depth index", nn)

    defVar(ds, "time", Float64, ("cycle", "phase", "time index"))
    defVar(ds, "depth", Float64, ("depth index",))
    defVar(ds, var, Float64, ("cycle", "phase", "time index", "depth index"))

    close(ds)

end



function init_station_data(filename::String, lendepths::Int)

    ds = NCDataset(filename, "c")

    defDim(ds, "cycle", Inf)
    defDim(ds, "phase", 2)
    defDim(ds, "depth index", lendepths)
    defDim(ds, "time index", Inf)

    
    defVar(ds, "time", Float64, ("cycle", "phase", "time index",))
    defVar(ds, "depths", Float64, ("depth index",))
    defVar(ds, "δ", Float64, ("cycle", "phase", "depth index", "time index"))
    defVar(ds, "V", Float64, ("cycle", "phase", "depth index", "time index"))
    defVar(ds, "τ", Float64, ("cycle", "phase", "depth index", "time index"))
    defVar(ds, "ψ", Float64, ("cycle", "phase", "depth index", "time index"))
           
    close(ds)

end
