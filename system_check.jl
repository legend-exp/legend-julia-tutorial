# This script is licensed under the MIT License (MIT).

jupyter_cmds = ["jupyter"]
python_cmds = ["python3", "python"]


function detect_application(
    application_name::AbstractString,
    envvar_name::AbstractString,
    julia_pkg_name::AbstractString,
    python_pkg_name::AbstractString,
    command_candidates::AbstractVector{<:AbstractString}
)
    if get(ENV, envvar_name, nothing) == ""
        @info "\$$envvar_name is set to \"$(ENV[envvar_name])\", $julia_pkg_name will create a Julia-internal Conda installation for $python_pkg_name."
    else
        if haskey(ENV, envvar_name)
            cmd_name = ENV[envvar_name]
        else
            cmd_idxs = findall(!isequal(nothing), Sys.which.(command_candidates))
            if !isempty(cmd_idxs)
                cmd_name = command_candidates[first(cmd_idxs)]
            else
                @error "No $(join(command_candidates, " or ")) command available, consider installing Anaconda and adding the Anaconda \"bin\" directory to your \$PATH"
                exit(1)
            end
        end

        try
            cmd_version = chomp(read(`$cmd_name --version`, String))
            ENV[envvar_name] = cmd_name
            @info "Using command \"$cmd_name\" for $application_name, $application_name version $cmd_version"
        catch err
            @error "Trying to use $application_name command \"$cmd_name\", but \"$cmd_name --version\" fails."
            exit(1)
        end

        if application_name == "Python"
            try
                read(`$cmd_name -c "import matplotlib.pyplot"`, String)
                @info "Python can import matplotlib.pyplot"
            catch err
                @error "Python cannot import matplotlib.pyplot, consider installing Anaconda and adding the Anaconda \"bin\" directory to your \$PATH"
                exit(1)
            end
        end
    end
end

detect_application("Jupyter", "JUPYTER", "PyCall.jl/PyPlot.jl", "Jupyter", jupyter_cmds)
detect_application("Python", "PYTHON", "PyCall.jl/PyPlot.jl", "matplotlib/PyPlot", python_cmds)
