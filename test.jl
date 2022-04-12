using GLMakie


let
    f = Figure()
    ax = Axis(f[1,1])
    len = 10000
    y = repeat(Float32.([1,2,3,4,NaN]), len)
    x = Float32[1,2,3,4, NaN]
    for i in 1:len-1
        x = hcat(x,[1 + i, 2 + i, 3+i, 4+i, NaN])
    end
    x = reshape(x, :)
    display(x)
    display(y)
    
    lines!(ax, x, y)
    current_figure()
end

