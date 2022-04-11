export convert_fault
export convert_stations, convert_volume, convertfolder

"""
    convert_fault(slipfname::String, filename::String)

    Rewrites a fault file fault_fname for variable var as described in SEAS benchmark problems to a NetCDF file called filename.
"""
function convert_fault(fault_fname::String, filename::String, var::String)
    
    # get slip data from benchmark format
    file = open(fault_fname, "r")
    fdata = collect(eachline(file))

    fault_file = NCDataset(filename, "a")
    
    yline = get_line(fdata, 1)
    linesize = length(yline)
    line = zeros(linesize)
    
    y = yline[3:end]
    fault_file["depth"] .= y

    cycle = 1
    phase = 1
    t_ind = 1

    @printf "Rewritting:\n"
    # loop through and create dictionary
    for i in 2:size(fdata)[1]
        @printf "\r%f%%" 100 * i/(size(fdata)[1]-3)
        if fdata[i] == "BREAK"
            if phase == 1
                phase = 2
                t_ind = 1
            elseif phase == 2
                phase = 1
                cycle += 1
                t_ind = 1
            end
        else
            line .= get_line(fdata, i)
            fault_file["time"][cycle, phase, t_ind] = line[1]
            fault_file[var][cycle, phase, t_ind, :] .= line[3:end]
            t_ind += 1
        end
    end
    
    close(fault_file)
    close(file)
    
end


function convert_stations(dir_name::String, filename::String, depths::AbstractVector)


    station_file = NCDataset(filename, "a")

    station_file["depths"] .= depths

    cycle = 1
    phase = 1
    t_ind = 1
     @printf "On station: "
    for (i, depth) in enumerate(depths)
       @printf "\r%d" i
        fdata = readdlm(string(dir_name, "station_", depth))[2:end, :]

        for k in 1:size(fdata)[1]

            if fdata[k,1] == "BREAK"
                if phase == 1
                    phase = 2
                    t_ind = 1
                elseif phase == 2
                    phase = 1
                    cycle += 1
                    t_ind = 1
                end
            else
                
                if i == 1
                    station_file["time"][cycle, phase, k] = fdata[t_ind,1]
                end
                
                station_file["δ"][cycle, phase, i, t_ind] = fdata[k, 2]
                station_file["V"][cycle, phase, i, t_ind] = fdata[k, 3]
                station_file["τ"][cycle, phase, i, t_ind] = fdata[k, 4]
                station_file["ψ"][cycle, phase, i, t_ind] = fdata[k, 5]
                
            end
        end
    end
    
    close(station_file) 

end

