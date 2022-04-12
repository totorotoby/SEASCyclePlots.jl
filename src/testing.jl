using NCDatasets
using GLMakie
using Interpolations

function interp_slip(slip_file
    slip_data = NCDataset("../test_make/slip.nc")
    switches = get_cycles("../test_make/")
