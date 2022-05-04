# Abstract types
# -----------------------------------------------------------------------------


abstract type AbstractGBDFilename end
abstract type AbstractVariableGBDFilename <: AbstractGBDFilename end
abstract type AbstractV20Filename <: AbstractGBDFilename end


# Structs
# -----------------------------------------------------------------------------


"""
"""
struct BaseGBDFilename{T <: AbstractString} <: AbstractGBDFilename

    dir::T
    date::T
    prefix::T
    suffix::T

    function BaseGBDFilename(dir::T, date::T, prefix::T, suffix::T) where {T}
        new{T}(dir, date, prefix, suffix)
    end

end


"""
"""
struct VariableGBDFilename{T <: AbstractString} <: AbstractVariableGBDFilename

    dir::T
    date::T
    prefix::T
    var::T
    suffix::T

    function VariableGBDFilename(
                dir::T,
                date::T,
                prefix::T,
                var::T,
                suffix::T
            ) where {T}
        new{T}(dir, date, prefix, var, suffix)
    end

    function VariableGBDFilename(base::BaseGBDFilename, var::T) where {T}
        new{T}(base.dir, base.date, base.prefix, var, base.suffix)
    end

end


"""
"""
struct BaseV20Filename{T <: AbstractString} <: AbstractV20Filename

    dir::T
    date::T
    subdir::T
    prefix::T
    suffix::T

    function BaseV20Filename(
                dir::T,
                date::T,
                subdir::T,
                prefix::T,
                suffix::T
            ) where {T}
        new{T}(dir, date, subdir, prefix, suffix)
    end

end


"""
"""
struct V20Filename{T <: AbstractString} <: AbstractV20Filename

    dir::T
    date::T
    subdir::T
    prefix::T
    suffix::T
    index::T
    year::T
    month::T

    function V20Filename(
                dir::T,
                date::T,
                subdir::T,
                prefix::T,
                suffix::T,
                index::T,
                year::T,
                month::T
            ) where {T}
        new{T}(dir, date, subdir, prefix, suffix, index, year, month)
    end

    function V20Filename(
                base::BaseV20Filename,
                index::T,
                year::T,
                month::T
            ) where {T}
        new{T}(
            base.dir,
            base.date,
            base.subdir,
            base.prefix,
            base.suffix,
            index,
            year,
            month)
    end

end


# Method implementations
# -----------------------------------------------------------------------------


"""
    Base.string(x::VariableGBDFilename)::String

Method overload for `Base.string`, to build a string from a
`VariableGBDFilename` object.

Joins `var` and `suffix` without a separator, and joins the complete path
separated by a single solidus.

Modified to filter out certain possibly empty components, such as dates or
prefixes.
"""
function Base.string(x::VariableGBDFilename)::String

    local basename::String
    local dirname::String

    basename = string(filter(isempty, [x.prefix, x.var, x.suffix])...)
    dirname = join(filter(isempty, [x.dir, x.date]), "/")

    return join([dirname, basename], "/")

end


"""
    Base.string(x::V20Filename)::String

Method overload for `Base.string`, to build a string from a `V20Filename`
object.

Joins `prefix`, `index`, `year`, `month`, and `suffix` with a single full stop,
making the indexed basename.  Joins `subdir` and `index` without a separator,
making the indexed subdirectory.  Joins `dir` and `date` to the joined indexed
subdirectory and indexed basename components, all with a solidus.

Modified to filter out certain possibly empty components, such as dates.
"""
function Base.string(x::V20Filename)::String

    local basename::String
    local basename_fragment::String
    local dirname::String

    basename_fragment = join([x.index, x.year, x.month], ".")
    basename = string(filter(isempty, [x.prefix, basename_fragment, x.suffix]))
    dirname =
        join(filter(isempty, [x.dir, x.date, string(x.subdir, x.index)]), "/")

    return join([dirname, basename], "/")

end
