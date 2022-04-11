export convert_fault
export convert_stations, convert_folder

"""
    convert_fault(fault_fname::String, filename::String, var::String)

Rewrites a fault file `fault_fname` for variable `var` as described in SEAS benchmark problems to a NetCDF file called `filename`.
"""
function convert_fault(fault_fname::String, filename::String, var::String)
    
    file = open(fault_fname, "r")
    fdata = collect(eachline(file))

    fault_file = NCDataset(filename, "a")
    
    yline = get_line(fdata, 1)
    linesize = length(yline)
    line = zeros(linesize)
    
    y = yline[3:end]
    fault_file["depth"] .= y

    @printf "Rewritting:\n"
    t_ind = 1
    for i in 2:size(fdata)[1]
        @printf "\r%f%%" 100 * i/(size(fdata)[1]-3)
        if fdata[i] == "BREAK"
            
        else
            line .= get_line(fdata, i)
            fault_file["time"][t_ind] = line[1]
            fault_file["maximum V"][t_ind] = line[2]
            fault_file[var][t_ind, :] .= line[3:end]
            t_ind += 1
        end
    end

    @printf "\n"
    
    close(fault_file)
    close(file)
    nothing
    
end

"""
    convert_stations(dir_name::String, filename::String, depths::AbstractVector)

Rewrites the station files at `depths` from directory `dir_name`, as described in SEAS benchmark problems, to a NetCDF file called `filename`.
"""
function convert_stations(dir_name::String, filename::String, stations::AbstractVector)


    station_file = NCDataset(filename, "a")

    station_file["stations"] .= stations

     @printf "on station: \n"
    for (i, station) in enumerate(stations)
       @printf "\r%d" i
        fdata = readdlm(string(dir_name, "station_", station))[2:end, :]
        t_ind = 1
        for k in 1:size(fdata)[1]

            if fdata[k,1] == "BREAK"
            else
                if i == 1
                    station_file["time"][t_ind] = fdata[k,1]
                end
                station_file["δ"][i, t_ind] = fdata[k, 2]
                station_file["V"][i, t_ind] = fdata[k, 3]
                station_file["τ"][i, t_ind] = fdata[k, 4]
                station_file["ψ"][i, t_ind] = fdata[k, 5]
                t_ind += 1
            end
        end
    end
    @printf "\n"
    close(station_file) 
    nothing
    
end


"""
    convert_folder(dir_name::String, new_dir::String , stations::AbstractVector, nn::Int)

Rewrites all files in the directory `dir_name` storing SEAS benchmark data with stations at `stations`, and a total of `nn` nodes per dimension, to a new folder `new_dir`.

"""
function convert_folder(dir_name::String, new_dir::String , stations::AbstractVector, nn::Int)

    if !isdir(new_dir)
        mkdir(new_dir)
    else
        error("new directory already exists.")
    end

    δ_name = string(new_dir, "slip.nc")
    V_name = string(new_dir, "slip_rate.nc")
    τ_name = string(new_dir, "stress.nc")
    ψ_name = string(new_dir, "state.nc")
    stations_name = string(new_dir, "stations.nc")
    
    init_fault_data(δ_name, "δ", nn)
    init_fault_data(V_name, "V", nn)
    init_fault_data(τ_name, "τ", nn)
    init_fault_data(ψ_name, "ψ", nn)
    init_station_data(stations_name, length(stations))

    
    @printf "making stations files...\n"
    convert_stations(dir_name, string(new_dir, "stations.nc"), stations)
    @printf "finished stations file\n"

    @printf "making slip file...\n"
    convert_fault(string(dir_name, "slip.dat"), δ_name, "δ")
    @printf "finished slip file\n"
    
    @printf "making slip rate file...\n"
    convert_fault(string(dir_name, "slip_rate.dat"), V_name, "V")
    @printf "finished slip rate file\n"

    @printf "making stress file...\n"
    convert_fault(string(dir_name, "stress.dat"), τ_name, "τ")
    @printf "finished stress file\n"

    @printf "making state file...\n"
    convert_fault(string(dir_name, "state.dat"), ψ_name, "ψ")
    @printf "finished state file\n"

    cp(string(dir_name, "input_file.dat"), string(new_dir, "input_file.dat"))
    
end

