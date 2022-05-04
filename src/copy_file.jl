# Source inclusions
# -----------------------------------------------------------------------------


include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
    copy_file(
        from::T,
        to::T
    ) where {T <: Union{VariableGBDFilename, V20Filename}}

Construct and run a command for copying a variable GBD file or V20 file from
the previous structure into the newer structure.
"""
function copy_file(
            from::T,
            to::T
        ) where {T <: Union{VariableGBDFilename, V20Filename}}

    local cmd::Base.CmdRedirect

    cmd = pipeline(
        `cp $(string(from)) $(string(to))`;
        stdout=devnull,
        stderr=devnull)

    run(cmd)

end


"""
"""
function copy_file(from::String, to::String)

    local cmd::Base.CmdRedirect

    cmd = pipeline(`cp $from $to`; stdout=devnull, stderr=devnull)

    run(cmd)

end
