# Source inclusions
# -----------------------------------------------------------------------------


include("regex_escape.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
"""
function find_intervention(template::BaseGBDFilename)::Vector{VariableGBDFilename}

    local indices::Vector{String}

    indices = find_intervention_years(template)

    return map(x -> VariableGBDFilename(template, x), indices)

end


"""
"""
function find_intervention_years(template::BaseGBDFilename)::Vector{String}

    local path_fragment::String
    local pattern::Regex
    local years::Vector{String}

    path_fragment = string(template.dir, "/", template.date)

    pattern = Regex(string(
        "^",
        regex_escape(path_fragment),
        "/",
        regex_escape(template.prefix),
        "(?P<var>\\d{4})",
        regex_escape(template.suffix),
        "\$"))

    years = reduce(
        (a, c) -> reduce_file_list_intervention(a, c, pattern),
        readdir(path_fragment; join=true);
        init=Vector{String}())

    return years

end


"""
"""
function make_intervention_new(
            template::BaseGBDFilename,
            incoming::VariableGBDFilename
        )::VariableGBDFilename

    VariableGBDFilename(template, incoming.var)

end


"""
"""
function reduce_file_list_intervention(
            acc::Vector{String},
            crt::String,
            pattern::Regex
        )::Vector{String}

    local m::Union{Nothing, RegexMatch}
    local year::String

    m = match(pattern, crt)

    if !(isnothing(m))
        push!(acc, getindex(m, "var"))
    end

    return acc

end
