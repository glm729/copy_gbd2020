# Source inclusions
# -----------------------------------------------------------------------------


include("regex_escape.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


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
    local dir_inner_parts::Vector{String}
    local dir_sub::String
    local file_data::Vector{Dict{Symbol, String}}
    local file_list::Vector{String}

    dir_sub = string(template.subdir, index)

    dir_inner_parts = filter(
        !isempty,
        [template.dir, template.date, dir_sub, template.prefix])

    dir_inner = dirname(join(dir_inner_parts, "/"))

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
    find_v20(template::BaseV20Filename)::Vector{V20Filename}

Find all V20 filenames matching the given `BaseV20Filename` template.
"""
function find_v20(template::BaseV20Filename)::Vector{V20Filename}

    local prefix::String
    local directory::Vector{String}
    local indices::Vector{String}
    local subdir_pattern::Regex
    local v20_rex::Regex

    prefix =
        join(map(x -> getproperty(template, x), [:dir, :date, :subdir]), "/")

    subdir_pattern = Regex(string(regex_escape(template.subdir), "\\d+\$"))

    v20_rex = Regex(string(
        "^",
        basename(regex_escape(template.prefix)),
        "\\d+\\.(?P<year>\\d{4})\\.(?P<month>\\d{2})",
        regex_escape(template.suffix),
        "\$"))

    directory = filter(
        x -> occursin(subdir_pattern, x),
        readdir(dirname(prefix); join=false))

    indices = map(x -> replace(x, template.subdir => ""), directory)

    return vcat(map(x -> find_files_v20(x, template, v20_rex), indices)...)

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
