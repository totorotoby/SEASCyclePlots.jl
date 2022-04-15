export get_cycles, slip_plot, station_plot


"""
    slip_plot(dirname::String, startfinish::Tuple{Integer, Integer}, spacing::Tuple{AbstractFloat, AbstractFloat})

Creates and displays a cummulative slip plot from directory `dirname` that begins at `start_cycle`, and ends at `finish_cycle`.
"""
function slip_plot(dirname::String, startfinish::Tuple{Integer, Integer}, spacing::Tuple{AbstractFloat, AbstractFloat})


    inds, time, depth, δ = get_slice(dirname, startfinish)

    dp = [depth ; NaN]
    
    temp_ind = [i for i in 1:length(depth)]
    
    f = Figure()
    ax = Axis(f[1,1], yreversed=true)
    
    δ_off = @view δ[:, inds[1]]
    # loop over indivdual cycles
    for i in 1:length(inds)-1
        
        b_ind, f_ind = inds[i], inds[i+1]

        δ_cycle = δ[:, b_ind:f_ind] .- δ_off
        t_cycle = @view time[b_ind:f_ind]

        if spacing != nothing
            if i % 2 == 1
                t_interp = t_cycle[1]:spacing[1] * year_seconds:t_cycle[end]
            else
                t_interp = t_cycle[1]:spacing[2]:t_cycle[end]
            end
            
            interp = interpolate((depth, t_cycle),
                                 δ_cycle,
                                 (Gridded(Linear()), Gridded(Linear())))
            
            δ_interp = interp(depth, t_interp)
            δ_plot, depth_plot = plot_process(δ_interp, dp)
        else
            δ_plot, depth_plot = plot_process(δ_cycle, dp)
        end
            
        if i % 2 == 1 
            lines!(ax, depth_plot, δ_plot, color=:blue)
        elseif i % 2 == 0
            lines!(ax, depth_plot, δ_plot, color=:red)
        end       

    end
        return f
end


function station_plot(dirname::String, station::AbstractFloat, startfinish::Tuple{Integer, Integer}, vars::Tuple)

    inds, loc_inds = get_inds(dirname, startfinish)

    station_data = NCDataset(string(dirname, "stations.nc"))
    stations = station_data["stations"][:]::Array{Float64, 1}
    s_ind = findfirst(x->x==station, stations)

    f = Figure()
    
    for (i, var) in enumerate(vars)
        data = station_data[var][inds[1]:inds[end],s_ind]::Array{Float64, 1}
        t = station_data["time"][inds[1]:inds[end]]::Array{Float64,1}
        ax = Axis(f[i,1])
        lines!(ax, t, data)
    end
  

    return f
    
end
    


function plot_process(δ::AbstractArray, depth::Array{Float64, 1})

    δ_plot = zeros((size(δ)[1] + 1) * size(δ)[2])
    depth_plot = zeros((size(δ)[1] + 1) * size(δ)[2])
    δ = vcat(δ, repeat([NaN], size(δ)[2])')
    temp_dim = size(δ)[2]
    δ_plot .= reshape(δ, :)
    depth_plot = repeat(depth, temp_dim)

    return depth_plot, δ_plot
    
end

function get_inds(dirname::String, startfinish::Tuple{Integer, Integer})

    cycle_ind = get_cycles(string(dirname))
    inds = cycle_ind[2 * startfinish[1]: 2*startfinish[2]]
    loc_inds = [(inds[i] - inds[1]) + 1 for i in 1:length(inds)]
    return inds, loc_inds
end



function get_slice(dirname::String, startfinish::Tuple{Integer, Integer})

    inds, loc_inds = get_inds(dirname, startfinish)
    slip_data = NCDataset(string(dirname, "slip.nc"))
    time = slip_data["time"][inds[1]:inds[end]]::Array{Float64,1}
    δ = slip_data["δ"][:,inds[1]:inds[end]]::Array{Float64, 2}
    depth = slip_data["depth"][:]::Array{Float64,1}

    return loc_inds, time, depth, δ
    
end


"""
    switches = get_cycles(dirname::String) 

Gets the indexes at which interseismic and coseismic periods begin and end from directory `dirname`, and stores them in `switches`.

"""
function get_cycles(dirname::String)

    cycle_file = string(dirname, "cycle.dat")
    switches = Integer[]
    if isfile(cycle_file)
        switches = readdlm(cycle_file, Int64)
    else
        slip_data = NCDataset(string(dirname, "slip.nc"))
        Vmax = slip_data["maximum V"][:]::Array{Float64, 1}
        dynam = false
        for (i, Vm) in enumerate(Vmax)
            if Vm > log(.1) && dynam == false
                push!(switches, i)
                dynam = true
            elseif Vm < log(.05) && dynam == true
                push!(switches, i)
                dynam = false
            end
        end

        writedlm(cycle_file, switches)
        
    end
    
    return switches

end
