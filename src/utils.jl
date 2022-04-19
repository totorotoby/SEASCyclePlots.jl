parse_line(line) = map(x -> parse(Float64,x), split.(line))
get_line(data, i) = map(x -> parse(Float64, x), split.(data[i]))
get_last(data) = map(x -> parse(Float64, x), split.(data[end]))
