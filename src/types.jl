abstract type AbstractGBDFilename end
abstract type AbstractVariableGBDFilename <: AbstractGBDFilename end
abstract type AbstractV20Filename <: AbstractGBDFilename end


"""
"""
struct BaseGBDFilename <: AbstractGBDFilename

    dir::T where {T <: AbstractString}
    date::T where {T <: AbstractString}
    suffix::T where {T <: AbstractString}

    BaseGBDFilename(dir, date, suffix) = new(dir, date, suffix)

end


"""
"""
struct VariableGBDFilename <: AbstractVariableGBDFilename

    dir::T where {T <: AbstractString}
    date::T where {T <: AbstractString}
    var::T where {T <: AbstractString}
    suffix::T where {T <: AbstractString}

    VariableGBDFilename(dir, date, var, suffix) = new(dir, date, var, suffix)

end


"""
"""
struct BaseV20Filename <: AbstractV20Filename

    dir::T where {T <: AbstractString}
    date::T where {T <: AbstractString}
    subdir::T where {T <: AbstractString}
    prefix::T where {T <: AbstractString}
    suffix::T where {T <: AbstractString}

    BaseV20Filename(dir, date, subdir, prefix, suffix) =
        new(dir, date, subdir, prefix, suffix)

end


"""
"""
struct V20Filename <: AbstractV20Filename

    dir::T where {T <: AbstractString}
    date::T where {T <: AbstractString}
    subdir::T where {T <: AbstractString}
    prefix::T where {T <: AbstractString}
    suffix::T where {T <: AbstractString}
    year::T where {T <: AbstractString}
    month::T where {T <: AbstractString}

    V20Filename(dir, date, subdir, prefix, suffix, year, month) =
        new(dir, date, subdir, prefix, suffix, year, month)

end
