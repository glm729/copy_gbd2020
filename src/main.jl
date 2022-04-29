#!/usr/bin/env julia


using JSON

include("read_spec.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
    regex_escape(str::String)::String

Escape special characters in a string for inclusion in construction of a
regular expression object.
"""
function regex_escape(str::String)::String

    local special_chars::Vector{String}
    local split_output::Vector{String}
    local split_string::Vector{String}

    special_chars = split("\\^\$.[]{}()|?*+", "")

    split_string = split(str, "")

    split_output = map(
        x -> any(y -> x == y, special_chars) ? "\\$x" : x,
        split_string)

    return join(split_output, "")

end


"""
    find_v20(template::BaseV20Filename)::Vector{V20Filename}

Find all V20 filenames matching the given `BaseV20Filename` template.
"""
function find_v20(template::BaseV20Filename)::Vector{V20Filename}

    local prefix::String
    local directory::String
    local indices::Vector{String}
    local v20_rex::Regex

    prefix =
        join(map(x -> getproperty(template, x), [:dir, :date, :subdir]), "/")

    v20_rex = Regex(string(
        "^",
        basename(regex_escape(template.prefix)),
        "\\d+\\.(?P<year>\\d{4})\\.(?P<month>\\d{2})",
        regex_escape(template.suffix),
        "\$"))

    directory = dirname(prefix)

    indices = map(
        x -> replace(x, template.subdir => ""),
        readdir(directory; join=false))

    return vcat(map(x -> find_files_v20(x, template, v20_rex), indices)...)

end


"""
    find_files_v20(
        index::String,
        template::BaseV20Filename,
        pattern::Regex
    )::Vector{V20Filename}

Find a set of V20 filenames for the given template, index, and filename
pattern.

The filename pattern is passed in to avoid constructing the regular expression
multiple times.
"""
function find_files_v20(
            index::String,
            template::BaseV20Filename,
            pattern::Regex
        )::Vector{V20Filename}

    local dir_inner::String
    local dir_sub::String
    local file_data::Vector{Dict{Symbol, String}}
    local file_list::Vector{String}

    dir_sub = string(template.subdir, index)

    dir_inner = dirname(
        join([template.dir, template.date, dir_sub, template.prefix], "/"))

    file_list = readdir(dir_inner)

    file_data = reduce(
        (a, c) -> reduce_file_list_v20(a, c, pattern),
        file_list;
        init=Vector{Dict{Symbol, String}}())

    return map(
        x -> V20Filename(template, index, x[:year], x[:month]),
        file_data)

end


"""
    make_v20_new(
        template::BaseV20Filename,
        incoming::V20Filename
    )::V20Filename

Fill in the template gaps to make a new `V20Filename`, given a template and an
incoming set of `V20Filename` data.
"""
function make_v20_new(
            template::BaseV20Filename,
            incoming::V20Filename
        )::V20Filename

    V20Filename(
        template,
        [incoming.index, incoming.year, incoming.month]...)

end


"""
    reduce_file_list_v20(
        acc::Vector{Dict{Symbol, String}},
        crt::String,
        pattern::Regex
    )::Vector{Dict{Symbol, String}}

Reduce the list of files to get month and year data for each relevant filename.
"""
function reduce_file_list_v20(
            acc::Vector{Dict{Symbol, String}},
            crt::String,
            pattern::Regex
        )::Vector{Dict{Symbol, String}}

    local m::Union{Nothing, RegexMatch}
    local month::String
    local year::String

    m = match(pattern, crt)

    if isnothing(m)
        return acc
    end

    month = getindex(m, "month")
    year = getindex(m, "year")

    push!(acc, Dict(:month => month, :year => year))

    return acc

end


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
