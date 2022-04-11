export get_cycles


"""
    slipplot(filename::String, start_cycle::Int, finish_cycle::Int)

Creates and displays a cummulative slip plot from `filename` that begins at `start_cycle`, and ends at `finish_cycle`.
"""
function slipplot(filename::String, start_cycle::Int, finish_cycle::Int)

    slip_data = NCDataset(filename)

    return slip_data
    
end


"""
    switches = get_cycles(dirname::String) 

Gets the indexes at which interseismic and coseismic periods begin and end from directory `dirname`, and stores them in `switches`.

"""
function get_cycles(dirname::String)

    cycle_file = string(dirname, "cycle.dat")
    switches = Int[]
    if isfile(cycle_file)
        switches = readdlm(cycle_file)
    else
        slip_data = NCDataset(string(dirname, "slip.nc"))
        Vmax = slip_data["maximum V"][:]::Array{Float64, 1}
        dynam = false
        for (i, Vm) in enumerate(Vmax)
            if Vm > log(.01) && dynam == false
                push!(switches, i)
                dynam = true
            elseif Vm < log(.001) && dynam == true
                push!(switches, i)
                dynam = false
            end
        end

        writedlm(cycle_file, switches)
        
    end
    
    return switches

end
