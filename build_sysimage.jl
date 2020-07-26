@assert isfile("legend-julia-software-tutorial.jmd")

orig_pwd = pwd()

scratchdir = mktempdir(prefix="legend_jl_pkgcompile_")
tmpprjdir = joinpath(scratchdir, basename(pwd()))
cp(pwd(), tmpprjdir)
cd(tmpprjdir)

import Pkg
Pkg.activate(".")
Pkg.rm("PyPlot")
Pkg.instantiate()
Pkg.precompile()

include("make.jl")

script = read("legend-julia-software-tutorial.jl", String)
# Remove versioninfo() from tutorial, causes trouble for PackageCompiler:
script = replace(script, "versioninfo()" => "")
# PackageCompiler doesn't seem to like Plots with pyplot():
script = replace(script, "pyplot()" => "")
open("legend-julia-software-tutorial.jl", "w") do f; write(f, script); end

import PackageCompiler, Libdl

custom_sysimg = joinpath(orig_pwd, "julia_sysimage." * Libdl.dlext)

PackageCompiler.create_sysimage(
    Symbol.(keys(Pkg.project().dependencies)),
    sysimage_path = custom_sysimg,
    precompile_execution_file = "legend-julia-software-tutorial.jl",
    cpu_target=PackageCompiler.default_app_cpu_target()
)

default_sysimg = abspath(Sys.BINDIR, "..", "lib", "julia", "sys." * Libdl.dlext)


import Markdown

show(Markdown.parse("
LEGEND Julia system image created.

Default Julia system image is \"$default_sysimg\", to use LEGEND Julia system image, run

```shell
julia --project=\"$orig_pwd\" --sysimage=\"$custom_sysimg\"
```

Run

```julia
julia> import IJulia
julia> IJulia.installkernel(\"LEGEND Julia\", \"--project=$orig_pwd\", \"--sysimage=$custom_sysimg\")
```

to install a Jupyter kernel that will use the LEGEND Julia system image.
"))
