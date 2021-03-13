# This program is licensed under the MIT License (MIT).
# Copyright (C) 2020 Oliver Schulz <oschulz@mpp.mpg.de>

orig_dir = @__DIR__
@assert isfile(joinpath(orig_dir, "legend-julia-software-tutorial.jmd"))

prj_dir = length(ARGS) >= 1 ? ARGS[1] : orig_dir
@assert isdir(prj_dir)
prj_dir = abspath(prj_dir)
@assert isfile(joinpath(prj_dir, "Project.toml")) && isfile(joinpath(prj_dir, "Manifest.toml"))

scratchdir = mktempdir(prefix="legend_jl_pkgcompile_")
tmp_dir = joinpath(scratchdir, basename(orig_dir))
cp(orig_dir, tmp_dir)
cd(tmp_dir)

import Pkg
Pkg.activate(prj_dir)
Pkg.instantiate()
Pkg.precompile()

include("make.jl")

import PackageCompiler, Libdl

custom_sysimg = joinpath(prj_dir, "JuliaSysimage." * Libdl.dlext)

PackageCompiler.create_sysimage(
    Symbol.(keys(Pkg.project().dependencies)),
    sysimage_path = custom_sysimg,
    precompile_execution_file = [
        "precompile_exec.jl",
        "legend-julia-software-tutorial.jl",
    ],
    cpu_target=PackageCompiler.default_app_cpu_target()
)


default_sysimg = abspath(Sys.BINDIR, "..", "lib", "julia", "sys." * Libdl.dlext)

import Markdown

show(Markdown.parse("
LEGEND Julia system image created.

Default Julia system image is \"$default_sysimg\", to start Julia with the LEGEND environment and system image, use

```shell
julia --project=\"$prj_dir\" --sysimage=\"$custom_sysimg\"
```

Run

```julia
julia> import IJulia
julia> IJulia.installkernel(\"LEGEND Julia\", \"--project=$prj_dir\", \"--sysimage=$custom_sysimg\")
```

to install a Jupyter Julia kernel that will use the LEGEND environment and system image.

To check which system image is active in a Julia session, use

```
julia> Base.JLOptions().image_file |> unsafe_string
```
"))
