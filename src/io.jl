export init_fault_data, init_station_data


"""
    init_fault_data(filename::String, var::String, nn::Int)

creates a NetCDF file called `filename` in which fault time series of variable `var` is stored at along a total of `nn` nodes.

"""
function init_fault_data(filename::String, var::String, nn::Int)

    ds = NCDataset(filename, "c")
    
    defDim(ds, "time index", Inf)
    defDim(ds, "depth index", nn)

    defVar(ds, "time", Float64, ("time index",))
    defVar(ds, "depth", Float64, ("depth index",))
    defVar(ds, "maximum V", Float64, ("time index",))
    defVar(ds, var, Float64, ("time index", "depth index"))

    close(ds)

end


"""
    init_station_data(filename::String, lendepths::Int)

 creates a NetCDF file called `filename` in which station time series data is stored in `lendepths` total stations.

"""
function init_station_data(filename::String, num_stations::Int)

    ds = NCDataset(filename, "c")

    defDim(ds, "station index", num_stations)
    defDim(ds, "time index", Inf)

    
    defVar(ds, "time", Float64, ("time index",))
    defVar(ds, "stations", Float64, ("station index",))
    defVar(ds, "δ", Float64, ("station index", "time index"))
    defVar(ds, "V", Float64, ("station index", "time index"))
    defVar(ds, "τ", Float64, ("station index", "time index"))
    defVar(ds, "ψ", Float64, ("station index", "time index"))
           
    close(ds)

end
