#!/usr/bin/env julia


# Module imports
# -----------------------------------------------------------------------------


using JSON


# Source inclusions
# -----------------------------------------------------------------------------


include("find_intervention.jl")
include("find_v20.jl")
include("read_spec.jl")
include("regex_escape.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
"""
function prepare_copy_list(spec)::Vector{Dict{Symbol, String}}

    local copy_list_interventions::Vector{Dict{Symbol, String}}
    local copy_list_v20::Vector{Dict{Symbol, String}}
    local iv_keys::Vector{String}
    local output::Vector{Dict{Symbol, String}}

    iv_keys = [
        "am",
        "irs",
        "itn",
    ]

    copy_list_interventions = vcat(map(
        x -> prepare_copy_list_intervention(get(spec, x, missing)),
        iv_keys)...)

    copy_list_v20 = prepare_copy_list_v20(get(spec, "v20", missing))

    return vcat(copy_list_interventions, copy_list_v20)

end


"""
"""
function prepare_copy_list_intervention(spec_iv)::Vector{Dict{Symbol, String}}

    local data_new::Vector{VariableGBDFilename}
    local data_old::Vector{VariableGBDFilename}

    data_old = find_intervention(spec_iv["from"])
    data_new = map(x -> make_intervention_new(spec_iv["to"], x), data_old)

    return map(
        x -> Dict(:from => string(x[1]), :to => string(x[2])),
        zip(data_old, data_new))

end


"""
"""
function prepare_copy_list_v20(spec_v20)::Vector{Dict{Symbol, String}}

    local data_new::Vector{V20Filename}
    local data_old::Vector{V20Filename}

    data_old = find_v20(spec_v20["from"])
    data_new = map(x -> make_v20_new(spec_v20["to"], x), data_old)

    return map(
        x -> Dict(:from => string(x[1]), :to => string(x[2])),
        zip(data_old, data_new))

end


# Main function
# -----------------------------------------------------------------------------


"""
"""
function main()

    local copy_list::Vector{Dict{Symbol, String}}
    local spec::Dict{String, Dict{String, AbstractGBDFilename}}

    spec = read_spec(ARGS[1])

    copy_list = prepare_copy_list(spec)

    open("TESTING.json", "w") do io
        JSON.print(io, copy_list, 4)
    end

end


# Entrypoint
# -----------------------------------------------------------------------------


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
