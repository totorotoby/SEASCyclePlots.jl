export init_fault_data, init_station_data, new_dir
export write_out_fault_data, write_out_stations

const vars_name = ("δ", "V", "τ", "ψ")

"""
    init_fault_data(filename::String, var::String, nn::Integer)

creates a NetCDF file called `filename` in which fault time series of variable `var` is stored at along a total of `nn` nodes.

"""
function init_fault_data(filename::String, var::String, nn::Integer, depth::Array{Float64, 1})

    ds = NCDataset(filename, "c")
    
    defDim(ds, "time index", Inf)
    defDim(ds, "depth index", nn)

    defVar(ds, "time", Float64, ("time index",))
    defVar(ds, "depth", Float64, ("depth index",))
    defVar(ds, "maximum V", Float64, ("time index",))
    defVar(ds, var, Float64, ("depth index", "time index"))

    ds["depth"][:] .= depth

    close(ds)

end


"""
    init_station_data(filename::String, lendepths::Integer)

 creates a NetCDF file called `filename` in which station time series data is stored in `lendepths` total stations.

"""
function init_station_data(filename::String, stations::Array{Float64,1})

    ds = NCDataset(filename, "c")

    defDim(ds, "station index", length(stations))
    defDim(ds, "time index", Inf)
    
    defVar(ds, "time", Float64, ("time index",))
    defVar(ds, "stations", Float64, ("station index",))
    defVar(ds, "δ", Float64, ("time index", "station index"))
    defVar(ds, "V", Float64, ("time index", "station index"))
    defVar(ds, "τ", Float64, ("time index", "station index"))
    defVar(ds, "ψ", Float64, ("time index", "station index"))
           
    ds["stations"][:] .= stations

    close(ds)

end


function init_volume_data(filename::String, x::Array{Float64,2}, y::Array{Float64,2})
    
    ds = NCDataset(filename, "c")

    



end


"""
    new_dir(new_dir::String, stations::AbstractVector, nn::Integer)

creates a new directory called `new_dir` to store data from `stations`, volume, and fault variables, for solutions with `nn` nodes per dimension.

"""
function new_dir(new_dir::String, input_file::String, stations::Array{Float64, 1}, depth::Array{Float64,1}, x::Array{Float64,2}, y::Array{Float64,2})

    if !isdir(new_dir)
        mkdir(new_dir)
    else
        #error("new directory already exists.")
    end

    nn = length(depth)

    δ_name = string(new_dir, "slip.nc")
    V_name = string(new_dir, "slip_rate.nc")
    τ_name = string(new_dir, "stress.nc")
    ψ_name = string(new_dir, "state.nc")
    stations_name = string(new_dir, "stations.nc")
    
    volume_name = string(new_dir, "volume.nc")
    

    init_fault_data(δ_name, "δ", nn, depth)
    init_fault_data(V_name, "V", nn, depth)
    init_fault_data(τ_name, "τ", nn, depth)
    init_fault_data(ψ_name, "ψ", nn, depth)
    init_station_data(stations_name, stations)
    #init_volume_data

    fault_names = [δ_name, V_name, τ_name, ψ_name]
    
    cp(input_file, new_dir)

    return fault_names, stations_name


end

"""
    write_out_fault_data(filenames::Tuple, vars::Tuple, t::Float64)

writes out `vars` fault varibles at time `t` to NetCDF `filenames`.

"""
function write_out_fault_data(filenames::Tuple, vars::Tuple, t::Float64)

    max_V = maximum(V)

    for (i , filename) in enumerate(filesnames)
        
        file = NCDataset(filename, "a")
        t_ind = size(file["time"])[1] + 1
        file["time"][t_ind] = t
        file["maximum V"][t_ind] = max_V
        file[vars_name[i]][:, t_ind] .= vars[i]
        
        close(file)
    end
        
end

"""
    write_out_stations(station_file::String, stations::AbstractVector, depth:: Array{Float64,1}, vars::Tuple)

writes out interpolated station data `vars` at `stations` using grid spacing `depth` at time `t` to netCDF file `station_file`.

"""
function write_out_stations(station_file::String, stations::Array{Float64,1}, depth::Array{Float64,1}, vars::Tuple, t::Float64)

    file = NCDataset(station_file, "a")
    t_ind = size(file["time"])[1] + 1
    file["time"][t_ind] = t

    inter_vars = []
    
    for var in vars
        interp = interpolate(depth, var, Gridded(Linear()))
        file[vars_name[i]][t_ind, :] .= interp
    end
    
    close(file)

end


function write_out_volume(

