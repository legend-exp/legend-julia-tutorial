import Pkg

Pkg.activate() # Activate default environment
Pkg.instantiate()

if !ispath(joinpath(first(DEPOT_PATH), "registries", "LegendJuliaRegistry"))
    @info("Installing Legend Julia package registry")
    Pkg.pkg"registry add General https://github.com/legend-exp/LegendJuliaRegistry.git"
else
    @info("Legend Julia package registry seems to be installed already.")
end


if !("IJulia" in keys(Pkg.project().dependencies))
    @info "Installing IJulia into default Julia environment \"$(Pkg.project().path)\""
    Pkg.add("IJulia"); Pkg.build("IJulia")
end


if !("Revise" in keys(Pkg.project().dependencies))
    @info "Installing IJulia into default Julia environment \"$(Pkg.project().path)\""
    Pkg.add("Revise")
end

config_dir = joinpath(first(DEPOT_PATH), "config")
mkpath(config_dir)

startup_jl = joinpath(config_dir, "startup.jl")
if !isfile(startup_jl)
    @info "Adding Revise initialization code to \"$startup_jl\"."
    write(startup_jl,
"""
try
    using Revise
catch e
    @warn "Error initializing Revise, try adding Revise.jl to your environment" exception=(e, catch_backtrace())
end
"""
    )
else
    @warn "File \"$startup_jl\" already exists, not adding Revise initialization code automatically."
end

startup_ijulia_jl = joinpath(config_dir, "startup_ijulia.jl")
if !isfile(startup_ijulia_jl)
    @info "Adding Revise initialization code to \"$startup_ijulia_jl\"."
    write(startup_ijulia_jl,
"""
try
    @eval using Revise
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end
"""
    )
else
    @warn "File \"$startup_ijulia_jl\" already exists, not adding Revise initialization code automatically."
end


if ispath("/usr/local/cuda")
    @info "Local CUDA installation detected, configuring Julia to use it."

    local_prefs_toml = joinpath(dirname(Pkg.project().path), "LocalPreferences.toml")
    if !isfile(local_prefs_toml)
        @info "Adding Revise initialization code to \"$local_prefs_toml\"."
        write(local_prefs_toml,
"""
[CUDA_Runtime_jll]
local = "true"
version = "local"
"""
        )
    else
        @warn "File \"$local_prefs_toml\" already exists, not setting local CUDA setting."
    end

    if !("CUDA_Runtime_jll" in keys(Pkg.project().dependencies))
        @info "Installing CUDA_Runtime_jll into default Julia environment \"$(Pkg.project().path)\""
        Pkg.add("CUDA_Runtime_jll")
    end
end 


@info "All done, enjoy using Julia for LEGEND!"
