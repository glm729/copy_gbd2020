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
    suffix::T

    function BaseGBDFilename(dir::T, date::T, suffix::T) where {T}
        new{T}(dir, date, suffix)
    end

end


"""
"""
struct VariableGBDFilename{T <: AbstractString} <: AbstractVariableGBDFilename

    dir::T
    date::T
    var::T
    suffix::T

    function VariableGBDFilename(dir::T, date::T, var::T, suffix::T) where {T}
        new{T}(dir, date, var, suffix)
    end

    function VariableGBDFilename(base::BaseGBDFilename, var::T) where {T}
        new{T}(base.dir, base.date, var, base.suffix)
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
"""
function Base.string(x::VariableGBDFilename)::String
    join([x.dir, x.date, "$(x.var)$(x.suffix)"], "/")
end


# """
# """
# function Base.string(x::V20Filename)
# end
