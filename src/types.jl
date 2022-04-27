abstract type AbstractGBDFilename end
abstract type AbstractVariableGBDFilename <: AbstractGBDFilename end
abstract type AbstractV20Filename <: AbstractGBDFilename end


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
    year::T
    month::T

    function V20Filename(
                dir::T,
                date::T,
                subdir::T,
                prefix::T,
                suffix::T,
                year::T,
                month::T
            ) where {T}
        new{T}(dir, date, subdir, prefix, suffix, year, month)
    end

end
