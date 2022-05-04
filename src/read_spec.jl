# Package and code requirements
# -----------------------------------------------------------------------------


using JSON

include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
"""
function get_spec_data_base_sub(data::Dict{String, String}, T::Type)

    local cs_data::Vector{String} =
        map(x -> get(data, string(x), missing), collect(fieldnames(T)))

    return T(cs_data...)

end


"""
"""
function get_spec_data_base(data::Dict{String, Dict{String, String}}, T::Type)

    local target_keys::Vector{String} = ["from", "to"]

    local target_data::Vector{Dict{String, String}} =
        map(x -> get(data, x, missing), target_keys)

    return Dict(zip(
        target_keys,
        map(x -> get_spec_data_base_sub(x, T), target_data)))

end


"""
    read_spec(
        path::AbstractString
    )::Dict{String, Dict{String, AbstractGBDFilename}}

Read and parse the file specification JSON, and coerce data into GBD filename
structures.
"""
function read_spec(
            path::AbstractString
        )::Dict{String, Dict{String, AbstractGBDFilename}}

    local intervention_keys::Vector{String}
    local v20_key::String

    local output::Dict{String, Dict{String, AbstractGBDFilename}}
    local spec::Dict{String, Dict{String, Dict{String, String}}}
    local v20_data::Dict{String, Dict{String, String}}

    intervention_keys = [
        "am",
        "irs",
        "itn",
    ]

    v20_key = "v20"

    spec = open(path, "r") do io
        JSON.parse(read(io, String))
    end

    output = Dict{String, Dict{String, BaseGBDFilename}}()

    for key in intervention_keys
        data = get(spec, key, missing)
        if ismissing(data)
            error("Required key missing: $key")
        end
        setindex!(output, get_spec_data_base(data, BaseGBDFilename), key)
    end

    v20_data = get(spec, v20_key, missing)
    if ismissing(v20_data)
        error("Required key missing: $v20_key")
    end

    setindex!(output, get_spec_data_base(v20_data, BaseV20Filename), v20_key)

    return output

end


# Main function
# -----------------------------------------------------------------------------


"""
"""
function main()

    println(ARGS)
    println(read_spec(ARGS[1]))

end


# Entrypoint
# -----------------------------------------------------------------------------


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
