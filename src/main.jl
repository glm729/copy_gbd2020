#!/usr/bin/env julia


# Module imports
# -----------------------------------------------------------------------------


using JSON


# Source inclusions
# -----------------------------------------------------------------------------


include("copy_file.jl")
include("find_intervention.jl")
include("find_v20.jl")
include("read_spec.jl")
include("regex_escape.jl")
include("types.jl")


# Function definitions
# -----------------------------------------------------------------------------


"""
    get_directories(
        copy_list::Vector{Dict{Symbol, String}}
    )::Vector{String}

Get all directories for files to copy, to create all required directories prior
to attempting to copy the files.
"""
function get_directories(
            copy_list::Vector{Dict{Symbol, String}}
        )::Vector{String}

    unique(map(x -> dirname(get(x, :to, missing)), copy_list))

end


"""
"""
function prepare_copy_list(spec)::Vector{Dict{Symbol, String}}

    local copy_list_interventions::Vector{Dict{Symbol, String}}
    local copy_list_v20::Vector{Dict{Symbol, String}}
    local iv_keys::Vector{String}
    local output::Vector{Dict{Symbol, String}}

    iv_keys = [
        "am",
        "irs",
        "itn",
    ]

    copy_list_interventions = vcat(map(
        x -> prepare_copy_list_intervention(get(spec, x, missing)),
        iv_keys)...)

    copy_list_v20 = prepare_copy_list_v20(get(spec, "v20", missing))

    return vcat(copy_list_interventions, copy_list_v20)

end


"""
"""
function prepare_copy_list_intervention(spec_iv)::Vector{Dict{Symbol, String}}

    local data_new::Vector{VariableGBDFilename}
    local data_old::Vector{VariableGBDFilename}

    data_old = find_intervention(spec_iv["from"])
    data_new = map(x -> make_intervention_new(spec_iv["to"], x), data_old)

    return map(
        x -> Dict(:from => string(x[1]), :to => string(x[2])),
        zip(data_old, data_new))

end


"""
"""
function prepare_copy_list_v20(spec_v20)::Vector{Dict{Symbol, String}}

    local data_new::Vector{V20Filename}
    local data_old::Vector{V20Filename}

    data_old = find_v20(spec_v20["from"])
    data_new = map(x -> make_v20_new(spec_v20["to"], x), data_old)

    return map(
        x -> Dict(:from => string(x[1]), :to => string(x[2])),
        zip(data_old, data_new))

end


# Main function
# -----------------------------------------------------------------------------


"""
"""
function main()

    local copy_list::Vector{Dict{Symbol, String}}
    local dirs_reqd::Vector{String}
    local spec::Dict{String, Dict{String, AbstractGBDFilename}}

    println("\033[36mReading file specification\033[m")
    spec = read_spec(ARGS[1])

    println("\033[36mPreparing list of files to copy\033[m")
    copy_list = prepare_copy_list(spec)

    println("\033[36mGetting directory list\033[m")
    dirs_reqd = get_directories(copy_list)

    println("\033[36mMaking required directories\033[m")
    foreach(mkpath, dirs_reqd)

    println("\033[36mPreparing copy tasks\033[m")
    task_list = map(
        x -> Task(() -> copy_file(x[:from], x[:to])),
        copy_list)

    println("\033[36mScheduling copy tasks\033[m")
    foreach(schedule, task_list)

    println("\033[36mWaiting for copy tasks to complete\033[m")
    foreach(wait, task_list)

    println("\033[36mDone\033[m")

end


# Entrypoint
# -----------------------------------------------------------------------------


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
