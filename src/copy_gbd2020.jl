# Package and code requirements
# -----------------------------------------------------------------------------


using JSON

include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
"""
function get_data_iv_base_sub(data::Dict{String, String})::BaseGBDFilename

    local cs_data::Vector{String} =
        map(
            x -> get(data, string(x), missing),
            collect(fieldnames(BaseGBDFilename)))

    return BaseGBDFilename(cs_data...)

end


"""
"""
function get_data_iv_base(
        spec_data::Dict{String, Dict{String, String}}
    )::Dict{String, BaseGBDFilename}

    local target_data::Vector{Dict{String, String}} =
        map(x -> get(spec_data, x, missing), ["from", "to"])

    return Dict(
        "from" => get_data_iv_base_sub(target_data[1]),
        "to" => get_data_iv_base_sub(target_data[2]),
    )

end


"""
"""
function get_data_v20_base(
        spec_data::Dict{String, Dict{String, String}}
    )::Dict{String, BaseV20Filename}

    #

end


"""
"""
function read_spec(
            path::AbstractString
        )::Dict{String, Dict{String, AbstractGBDFilename}}

    local intervention_keys::Vector{String}
    local v20_key::String

    local output::Dict{String, Dict{String, BaseGBDFilename}}
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
        setindex!(output, get_data_iv_base(data), key)
    end

    v20_data = get(spec, v20_key, missing)
    if ismissing(v20_data)
        error("Required key missing: $v20_key")
    end

    setindex!(output, get_data_v20_spec(v20_data), v20_key)

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
