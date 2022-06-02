#!/usr/bin/env julia


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
    prepare_copy_list(
        spec::Dict{String, Dict{String, AbstractGBDFilename}}
    )::Vector{Dict{Symbol, String}}

Collect and format all required filenames to copy, in sets of "from-to" pairs.
Search for the files list to copy from, and make the file list to copy to.
"""
function prepare_copy_list(
            spec::Dict{String, Dict{String, AbstractGBDFilename}}
        )::Vector{Dict{Symbol, String}}

    local copy_list_interventions::Vector{Dict{Symbol, String}}
    local copy_list_v20::Vector{Dict{Symbol, String}}
    local iv_data::Vector{Dict{String, BaseGBDFilename}}
    local iv_keys::Vector{String}
    local output::Vector{Dict{Symbol, String}}

    # Hardcoded set of interventions keys
    iv_keys = [
        "am",
        "irs",
        "itn",
    ]

    # Get interventions data as the correct type
    iv_data = map(
        x -> convert(Dict{String, BaseGBDFilename}, get(spec, x, missing)),
        iv_keys)

    copy_list_interventions =
        vcat(map(prepare_copy_list_intervention, iv_data)...)

    # Get the V20 copy list
    copy_list_v20 = prepare_copy_list_v20(
        convert(
            Dict{String, BaseV20Filename},  # Convert to the correct type
            get(spec, "v20", missing)))

    # Flatten the copy lists together
    return vcat(copy_list_interventions, copy_list_v20)

end


"""
    prepare_copy_list_intervention(
        spec_iv::Dict{String, BaseGBDFilename}
    )::Vector{Dict{Symbol, String}}

Collect and format required filename data for copying interventions files.
Separated due to different handling of V20 data compared to remaining
interventions data.
"""
function prepare_copy_list_intervention(
            spec_iv::Dict{String, BaseGBDFilename}
        )::Vector{Dict{Symbol, String}}

    local data_new::Vector{VariableGBDFilename}
    local data_old::Vector{VariableGBDFilename}

    data_old = find_intervention(spec_iv["from"])
    data_new = map(x -> make_intervention_new(spec_iv["to"], x), data_old)

    return map(
        x -> Dict(:from => string(x[1]), :to => string(x[2])),
        zip(data_old, data_new))

end


"""
    prepare_copy_list_v20(
        spec_v20::Dict{String, BaseV20Filename}
    )::Vector{Dict{Symbol, String}}

Collect and format required filename data for copying V20 files.  Separated due
to different handling of V20 data compared to remaining interventions data.
"""
function prepare_copy_list_v20(
            spec_v20::Dict{String, BaseV20Filename}
        )::Vector{Dict{Symbol, String}}

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
Given a data specification, run a multi-threaded copy operation.

This is multi-threaded as the remote machine uses a distributed storage drive
with PID-based or host-based access limitations.  This means that it is
possible to have multiple different physical drive accessors at the same moment
as the network drive is split across multiple physical drive, but only if there
are multiple different processes.
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
