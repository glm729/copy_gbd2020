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
        regex_escape(dirname(path_fragment)),  # Get inner directory
        "/",
        regex_escape(basename(path_fragment)),  # Get inner prefix
        "(?P<year>\\d{4})",
        regex_escape(template.suffix),
        "\$"))

    years = reduce(
        (a, c) -> reduce_file_list_intervention(a, c, pattern),
        readdir(dirname(path_fragment); join=true);
        init=Vector{String}())

    return years

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
        push!(acc, getindex(m, "year"))
    end

    return acc

end
