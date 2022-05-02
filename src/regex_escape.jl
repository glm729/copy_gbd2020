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
