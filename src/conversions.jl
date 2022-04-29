export convert_fault
export convert_stations, convert_folder

"""
    convert_fault(fault_fname::String, filename::String, var::String)

Rewrites a fault file `fault_fname` for variable `var` as described in SEAS benchmark problems to a NetCDF file called `filename`.
"""
function convert_fault(fault_files::Tuple, filename::String, nn::Int)
    
    write_file = NCDataset(filename, "a")
    
    line = zeros(nn + 2)

    sizes = []

    for (i, fault_name) in enumerate(fault_files)
        file = open(fault_name, "r")
        fdata = collect(eachline(file)) 
        push!(sizes, size(fdata)[1])
        close(file)
    end

    data_length = minimum(sizes)
    
    for (i, fault_name) in enumerate(fault_files)
        file = open(fault_name, "r")
        fdata = collect(eachline(file))
        t_ind = 1
        break_count = 1
        @printf "writing %s:\n" vars_name[i]
        for j in 2:data_length
            @printf "\r%f%%" 100 * j/data_length
            if fdata[j] != "BREAK"
                line .= get_line(fdata, j)
                if vars_name[i] == "δ"
                    write_file["maximum V"][t_ind] = line[2]
                    write_file["time"][t_ind] = line[1]
                end
                write_file[vars_name[i]][:, t_ind] .= line[3:end]
                t_ind += 1
            end
        end    
        @printf "\n"
        close(file)
    end
    #error()
    close(write_file)
        
    nothing
end


function get_depth(slip_file::String)

    file = open(slip_file, "r")
    fdata = collect(eachline(file))
    yline = get_line(fdata, 1)
    y = yline[3:end]

    close(file)

    return y

end


function get_xy(u_file::String)

    file = open(u_file, "r")
    iter = eachline(file)
    x, iter = firstrest(iter)
    x = parse_line(x)
    y, iter = firstrest(iter)
    y = parse_line(y)
    
    close(file)

    return x, y
    
end


"""
    convert_stations(dir_name::String, filename::String, depths::AbstractVector)

Rewrites the station files at `depths` from directory `dir_name`, as described in SEAS benchmark problems, to a NetCDF file called `filename`.
"""
function convert_stations(dir_name::String, filename::String, stations::AbstractVector)


    station_file = NCDataset(filename, "a")


    @printf "on station: \n"
    for (i, station) in enumerate(stations)
       @printf "\r%d" i
        fdata = readdlm(string(dir_name, "station_", station))[2:end, :]
        t_ind = 1
        for k in 1:size(fdata)[1]

            if fdata[k,1] != "BREAK"
                if i == 1
                    station_file["time"][t_ind] = fdata[k,1]
                end
                station_file["δ"][t_ind, i] = fdata[k, 2]
                station_file["V"][t_ind, i] = fdata[k, 3]
                station_file["τ"][t_ind, i] = fdata[k, 4]
                station_file["ψ"][t_ind, i] = fdata[k, 5]
                t_ind += 1
            end
        end
    end
    @printf "\n"
    close(station_file) 
    nothing
    
end


function convert_volume(volume_files::Tuple, filename::String)

    write_file = NCDataset(filename, "a")
    volume_vars = ("u", "v")
    
    x_len = length(write_file["x"][:])
    y_len = length(write_file["y"][:])

    N = x_len * y_len
    line = zeros(N)

    for (i, volume_file) in enumerate(volume_files)

        file = open(volume_file, "r")
        iter = Iterators.drop(eachline(file), 3)

        @printf "rewritting %s\n" volume_vars[i]
        for (j, line) in enumerate(iter)
            if line != "BREAK"
                var = reshape(parse_line(line), x_len, y_len)
                write_file["time"][j] = j
                write_file[volume_vars[i]][:, :, j] .= var
            end
        end

        close(file)
        
    end

    close(write_file)
    
end




"""
    convert_folder(dir_name::String, new_dir::String , stations::AbstractVector, nn::Integer)

Rewrites all files in the directory `dir_name` storing SEAS benchmark data with stations at `stations`, and a total of `nn` nodes per dimension, to a new folder `new_dir`.

"""
function convert_folder(dir_name::String, new_dir::String , stations::AbstractVector, nn::Integer)

    if !isdir(new_dir)
        mkdir(new_dir)
    else
        error("new directory already exists.")
    end

    fault_name = string(new_dir, "fault.nc")
    stations_name = string(new_dir, "stations.nc")

    depth = get_depth(string(dir_name, "slip.dat"))

    init_fault_data(fault_name, nn, depth)
    
    init_station_data(stations_name, stations)

    x, y = get_xy(string(dir_name, "us.dat"))
    
    init_volume_data(string(new_dir, "volume.nc"), x, y)
    
    @printf "making stations files...\n"
    convert_stations(dir_name, string(new_dir, "stations.nc"), stations)
    @printf "finished stations file\n"

    fault_files = (string(dir_name, "slip.dat"),
                   string(dir_name, "slip_rate.dat"),
                   string(dir_name, "stress.dat"),
                   string(dir_name, "state.dat"))
    
    convert_fault(fault_files, string(new_dir, "fault.nc"), nn)
                  
    volume_files = (string(dir_name, "us.dat"),
                    string(dir_name, "vs.dat"))
                  
    convert_volume(volume_files, string(new_dir, "volume.nc"))

    cp(string(dir_name, "input_file.dat"), string(new_dir, "input_file.dat"))
    
end

