#!/usr/bin/env julia


# Module imports
# -----------------------------------------------------------------------------


using JSON


# Source inclusions
# -----------------------------------------------------------------------------


include("find_v20.jl")
include("read_spec.jl")
include("regex_escape.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------





# Main function
# -----------------------------------------------------------------------------


"""
"""
function main()

    local spec::Dict{String, Dict{String, AbstractGBDFilename}}

    spec = read_spec(ARGS[1])

    # println(JSON.print(spec, 4))

    v20_old = find_v20(spec["v20"]["from"])

    v20_new = make_v20_new(spec["v20"]["to"], v20_old[1])

    println(string(v20_old[1]))
    println(string(v20_new))

end


# Entrypoint
# -----------------------------------------------------------------------------


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
