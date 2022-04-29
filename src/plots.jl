export get_cycles, slip_plot!, station_plot!, plot_switch!, plot_volume!, fault_animation!


"""
    slip_plot!(f::Figure, filename::String, startfinish::Tuple{Integer, Integer}, row::Int, col::Int, title::String; spacing=nothing, s_to_d=.01::Float64, d_to_s=.005::Float64)

Creates and displays a cummulative slip plot from file `filename` in figure `f` at (`row`,`col`) that begins at `startfinish[1]`, and ends at `startfinish[2]`, with a spacing of `spacing[1]` years in the interseismic phase and `spacing[2]` seconds in the coseismic phase.

Optional arguments:
`spacing::Tuple{Float64,Float64}` - interpolates contours in interseismic phases by `spacing[1]` years and coseismic phases by `spacing[2]` seconds.
`s_to_d::Float64` - sets the threshold of when the coseismic phase begins and the interseismic phase ends, by slip rate on the fault.
`d_to_s::Float64` - sets the threshold of when the interseismic phase begins and the coseismic phase ends, by slip rate on the fault.
"""
function slip_plot!(f::Figure, filename::String, startfinish::Tuple{Integer, Integer}, row::Int, col::Int, title::String; spacing=nothing, s_to_d=.01::Float64, d_to_s=.001::Float64)


    inds, time, depth, δ = get_slice(filename, "δ", startfinish; s_to_d=s_to_d, d_to_s=d_to_s)

    dp = [depth ; NaN]
    
    temp_ind = [i for i in 1:length(depth)]
    
    
    ax = Axis(f[row,col], yreversed=true, title=title, xlims=(0,25), xlabel="Cummulative Slip (m)", ylabel="Depth (Km)")

    #if startfinish[1] == 1
    #    δ_off = zeros(size(δ)[1])
    #else
        δ_off = @view δ[:, inds[1]]
    #end
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

"""
    station_plot!(f::Figure, dirname::String, filename::String, station::AbstractFloat, startfinish::Tuple{Integer, Integer}, var::String, row::Int, col::Int)

Creates and displays station time series of variables `var` from file `filename` in figure `f` at (`row`, `col`)  at station depth `station` beginning with cycle `startfinish[1]` and ending with `startfinish[2]`.

"""
function station_plot!(f::Figure, filename::String, station::AbstractFloat, startfinish::Tuple{Integer, Integer}, var::String, row::Int, col::Int)

    inds, loc_inds = get_inds(filename, startfinish, d_to_s=.0005)

    station_data = NCDataset(filename)
    stations = station_data["stations"][:]::Array{Float64, 1}
    s_ind = findfirst(x->x==station, stations)

    ax = Axis(f[row,col])
    
    data = station_data[var][inds[1]:inds[end],s_ind]::Array{Float64, 1}
    t = station_data["time"][inds[1]:inds[end]]::Array{Float64,1}

    data = station_data[var][:,s_ind]::Array{Float64, 1}
    t = station_data["time"][:]::Array{Float64,1}

    
    lines!(ax, t, data, color=:blue)
   
    return ax
    
end

function plot_switch!(f::Figure, filename::String, station::AbstractFloat, switch::Integer, switching_criteria::AbstractFloat, title::String)


    cycle_inds = get_cycles(filename; d_to_s=switching_criteria)

    begin_I = cycle_inds[2*switch + 1]

    start_ind = begin_I - 20
    end_ind = begin_I + 10

    count_ax = start_ind:1.0:end_ind
    
    station_data = NCDataset(filename)
    stations = station_data["stations"][:]::Array{Float64, 1}
    
    s_ind = findfirst(x->x==station, stations)
    display(station_data["maximum V"][begin_I])
    τ_data = station_data["τ"][start_ind:end_ind,s_ind]::Array{Float64, 1}
    V_data = station_data["V"][start_ind:end_ind,s_ind]::Array{Float64, 1}
    t = station_data["time"][start_ind:end_ind]::Array{Float64,1}

    ax1 = Axis(f[1, 1], title=string(title, ", τ"))
    ax2 = Axis(f[2, 1], title="V")
    ax3 = Axis(f[1, 2])
    ax4 = Axis(f[2, 2])
    
    lines!(ax1, t, τ_data)
    scatter!(ax1, t, τ_data)
    lines!(ax2, t, V_data)
    scatter!(ax2, t, V_data)

    lines!(ax3, count_ax, τ_data)
    scatter!(ax3, count_ax, τ_data)
    vlines!(ax3, begin_I, color=:red)

    lines!(ax4, count_ax, V_data)
    scatter!(ax4, count_ax, V_data)
    vlines!(ax4, begin_I, color=:red)
    return f
    
end


"""
    plot_volume!(f::Figure, filename::String, var::String, t_ind::Int, row::Int, col::Int)


Creates and displays a heatmap of volume variable `var` in figure `f` at (`row`, `col`) from the file `filename` at time index `t_ind`.

"""
function plot_volume!(f::Figure, filename::String, var::String, t_ind::Int, row::Int, col::Int)

    volume_data = NCDataset(filename)

    x = volume_data["x"][:]::Array{Float64,1}
    y = volume_data["y"][:]::Array{Float64,1}
    vv = volume_data[var][:, :, t_ind]::Array{Float64,2}

    max_v = maximum(vv)
    
    ax = Axis(f[row,col], yreversed=true)
    
    heatmap!(ax, x, y, vv, colorrange=(0.0, 1.0))
    
    return max_v
    
end

"""
    fault_animation!(f::Figure, dirname::String, vars::Array{String, 1}, startfinish::Tuple{Integer, Integer})

Creates, and saves an animation `

"""
function fault_animation!(f::Figure, filename::String, savefile::String, vars::Array{String, 1}, startfinish::Tuple{Integer, Integer})

    plot_vars = []
    slices = []
    axes = []
    time = 0
    t = Observable{Float64}(0.0)
    cycle = Observable{Float64}(Float64(startfinish[1])-1)
    v_inds = []
    
    for (i, var) in enumerate(vars)

        loc_inds, time, depth, var_slice = get_slice(dirname, var, startfinish)
        if i == 1
            ax = Axis(f[i,1], xlabel="depth(Km)", ylabel=var,
                      title=@lift("time: $(round($t, digits=3)), Cycle: $(round($cycle, digits=1))"))
        else
            ax = Axis(f[i,1], xlabel="depth(Km)", ylabel=var)
        end
        
        plot_var = Observable{Array{Float64,1}}(var_slice[:, 1])
        lines!(ax, depth, plot_var)
        push!(plot_vars, plot_var)
        push!(slices, var_slice)
        push!(axes, ax)
        push!(v_inds, loc_inds)
    end
    
    frames = 1:size(slices[1])[2]
    breaks = -1
    
    record(f, savefile, frames; framerate = 36) do i
        
        t[] = time[i]/year_seconds
            
        if i in v_inds[1]
            breaks += 1
            if breaks % 2 == 0
                cycle[] +=1.0
            end
        end
        
        for j in 1:length(plot_vars)
            plot_vars[j][] = slices[j][:, i]
            autolimits!(axes[j])
        end
    end
end


"""
    depth_plot, δ_plot = plot_process(δ::AbstractArray, depth::Array{Float64, 1})

A hacky way of reorginzing all of the δ contours so that there is less overhead when plotting...
"""
function plot_process(δ::AbstractArray, depth::Array{Float64, 1})

    δ_plot = zeros((size(δ)[1] + 1) * size(δ)[2])
    depth_plot = zeros((size(δ)[1] + 1) * size(δ)[2])
    δ = vcat(δ, repeat([NaN], size(δ)[2])')
    temp_dim = size(δ)[2]
    δ_plot .= reshape(δ, :)
    depth_plot = repeat(depth, temp_dim)

    return depth_plot, δ_plot
    
end

"""
    inds, loc_inds = get_inds(dirname::String, startfinish::Tuple{Integer, Integer})


Return local, and global indices in time from directory `dirname` where interseismic and coseismic periods begin and start, for the subset of cycles `startfinish[1]` to `startfinish[2]`.
"""
function get_inds(filename::String, startfinish::Tuple{Integer, Integer}; s_to_d=.01::Float64, d_to_s=.001::Float64)

    cycle_ind = get_cycles(filename; s_to_d=s_to_d, d_to_s=d_to_s)

    if  2*startfinish[2]+1 <= length(cycle_ind)
        inds = cycle_ind[2 * startfinish[1] - 1 : 2*startfinish[2]+1]
    else
        inds = cycle_ind[2 * startfinish[1] - 1 : 2*startfinish[2]]
    end
    loc_inds = [(inds[i] - inds[1]) + 1 for i in 1:length(inds)]
    return inds, loc_inds
end

"""
    loc_inds, time, depth, δ = get_slip_slice(dirname::String, startfinish::Tuple{Integer, Integer})

Returns the local indices, times, fault coordinates, and slip from the directory `dirname` of a slice of cumulative slip from `startfinish[1]` to `startfinish[2]`.

"""
function get_slice(filename::String, var::String, startfinish::Tuple{Integer, Integer}; s_to_d=.01::Float64, d_to_s=.001::Float64)

    inds, loc_inds = get_inds(filename, startfinish; s_to_d=s_to_d, d_to_s=d_to_s)
    data = NCDataset(filename)
    time = data["time"][inds[1]:inds[end]]::Array{Float64,1}
    var_slice = data[var][:,inds[1]:inds[end]]::Array{Float64, 2}
    depth = data["depth"][:]::Array{Float64,1}

    return loc_inds, time, depth, var_slice
    
end


"""
    switches = get_cycles(dirname::String) 

Gets the indexes at which interseismic and coseismic periods begin and end from directory `dirname`, and stores them in `switches`.

"""
function get_cycles(filename::String; s_to_d=.01::Float64, d_to_s=.001::Float64)

    #@show d_to_s
    #@show s_to_d

    data = NCDataset(filename)
    mV = data["maximum V"][:]::Array{Float64, 1}
    switches = Int64[1]
    dynam = false
    for i in 1:size(mV)[1]
        if maximum(mV[i]) > s_to_d && dynam == false
            push!(switches, i)
            dynam = true
        elseif maximum(mV[i]) < d_to_s && dynam == true
            push!(switches, i)
            dynam = false
        end
    end
    push!(switches, size(mV)[1])
    #@show size(switches)
    return switches

end
