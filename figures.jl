using SEASCyclePlots
using SEASCyclePlots.plots
using GLMakie
set_window_config!(; framerate=1.0)


paper_theme = Theme(fontsize=40, font="../computer-modern/cmunrm.ttf")
set_theme!(paper_theme)

f = Figure()

times = [13.0, 13.6, 13.8]
times2 = [15.1, 15.8, 16.0]
d_to_s = [.001, .001, .001]

fault_files = ["../Basin_data/basin_refinement/8GPa/3n_8/fault.nc",
               "../Basin_data/basin_refinement/8GPa/n6_8/fault.nc",
               "../Basin_data/basin_refinement/8GPa/n9_8/fault.nc"]

station_files = ["../Basin_data/basin_refinement/8GPa/3n_8/stations.nc",
                 "../Basin_data/basin_refinement/8GPa/n6_8/stations.nc",
                 "../Basin_data/basin_refinement/8GPa/n9_8/stations.nc"]

labels = ["3 nodes / Λ₀", "6 nodes / Λ₀", "9 nodes / Λ₀"]

f, ax1 = plot_fault_var!(f, fault_files, "V", 5, 1, 1, d_to_s, times, labels)
f, ax2 = plot_fault_var!(f, fault_files, "V", 5, 1, 2, d_to_s, times2, labels)

ax1.limits = (0, 17, 0, 7)
ax2.limits = (0, 7, 0, 7)

text!(ax1, "13.0 s", position=(.8, 1.2), textsize=28)
text!(ax1, "13.8 s", position=(15.5, .5), textsize=28)
text!(ax1, "13.6 s", position=(5, 1.2), textsize=28)

text!(ax2, "15.1 s", position=(.4, 1.2), textsize=28)
text!(ax2, "16.0 s", position=(6.3, 3.6), textsize=28)
text!(ax2, "15.8 s", position=(6.3, 4.2), textsize=28)

ax2.yticklabelsvisible=false
axislegend(ax1, position=:rb, patchsize=(60,35))

f, ax3 = plot_max_slip_rate!(f, station_files, (3, 16), 2, 1, d_to_s, labels)

ax3.limits = (750.0, 2500.0, -10.0, 2.0)


vlines!(ax3, [1675], linewidth=7, color=:black)
vlines!(ax3, [1675], linewidth=7, color=:red, linestyle=:dot)
vlines!(ax3, [2125], linewidth=7, color=:black)
vlines!(ax3, [2125], linewidth=7, color=:red, linestyle=:dot)

text!(ax3, "1st\ndivergence\nbegins", position=(1550, .5), textsize=28)
text!(ax3, "2nd\ndivergence\nbegins", position=(1990, .5), textsize=28)

hidedecorations!(ax1, label=false, ticklabels=false, ticks=false)
hidedecorations!(ax2, label=false, ticklabels=false, ticks=false)
hidedecorations!(ax3, label=false, ticklabels=false, ticks=false)


ax3.xlabel="time (yrs)"
ax3.ylabel="log10(max(V))"
ax1.ylabel = "depth (km)"
ax1.xlabel = "slip rate (m/s)"
ax2.xlabel = "slip rate (m/s)"

ax1.xtickalign = 1
ax2.xtickalign = 1
ax3.xtickalign = 1
ax1.ytickalign = 1
ax2.ytickalign = 1
ax3.ytickalign = 1
ax1.xticksize = 20
ax2.xticksize = 20
ax3.xticksize = 20
ax1.yticksize = 20
ax2.yticksize = 20
ax3.yticksize = 20

el1 = [LineElement(color=:midnightblue)]
el2 = [LineElement(color=:darkorange)]
el3 = [LineElement(color=:yellowgreen)]


text!(ax1 ,"(a)", position=(.5,6.8), textsize=40)
text!(ax2 ,"(b)", position=(6.5, .65), textsize=40)
text!(ax3 ,"(c)", position=(770, 1), textsize=40)

#=
Legend(f[1:2, 3],
       [el1, el2, el3],
       ["3 nodes / Λ₀", "6 nodes / Λ₀", "9 nodes / Λ₀"], patchsize=(70, 35))
=#

display(f)
