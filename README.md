# LEGEND Julia Software Stack Tutorial

This tutorial demonstrates the LEGEND Julia software stack: It shows how to simulate an inverted-coaxial HPGe detector, how to generate detector waveforms based on Geant4 MC results, how to reconstruct an energy spectrum from the simulated pulses and how to perform an auto-calibration of the resulting spectrum.

Note: This is a work in progress, more functionality will be added over time. The LEGEND-related software packages used are still under very active development, so types and functions may change without notice. This tutorial will be updated regularly and adapted to API changes.


## Required Software

The tutorial is offered in the form of a [Jupyter](https://jupyter.org/) notebook (also as a plain Julia script). So for full functionality, you need both Julia and a way to run Jupyter notebooks.


### Using the LEGEND software container image

The easiest way to ensure that all required software is available is to use the [LEGEND base software container](https://github.com/legend-exp/legendexp_legend-base_img) (see the link for instructions).

When using the container image, you can skip the complete installation section below.


### Installing Julia and optionally Jupyter or nteract

#### Installing Julia

Julia is easy to install:

* [Download Julia](https://julialang.org/downloads/).

* Extract the archive resp. run the installer.

* You may want to add the Julia "bin" directory to your `$PATH"`

We recommend using Julia v1.6 or later to run this tutorial.


#### Optional: Installing Jupyter

If you have a working Jupyter installation, it should detect the Jupyter Julia kernel that will be installed when you instantiate the LEGEND Julia environment (see below).

You can also start Jupyter via Julia: This can either use existing installations of Jupyter and pyplot, or install both internally by creating an internal Conda installation within `$HOME/.julia/conda`. On Linux, Julia will by default to use the Jupyter installation associated with the `jupyter` executable on your `$PATH`. On OS-X and Windows, both IJulia will by default always create a Julia-internal Conda installation (see above). To change this behavior, set the environment variable [`$JUPYTER`](https://github.com/JuliaLang/IJulia.jl#installation). For details, see the [IJulia.jl](https://github.com/JuliaLang/IJulia.jl#installation)documentation.

If you use Python packages from Julia (e.g. via PyPlot.jl, UpROOT.jl or directly via PyCall.jl),
the same default behavior occurs (the system's Python3 is used on Linux, a Julia-internal Conda environment on OS-X and Windows). To change this, set the [`$PYTHON`](https://github.com/JuliaPy/PyCall.jl#specifying-the-python-version) environment variable. For details, see the [PyCall.jl](https://github.com/JuliaPy/PyCall.jl#specifying-the-python-version) and [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) documentation.

If you want to use a standalone Jupyter/Python installation with Julia, we recommend to [install Anaconda](https://www.anaconda.com/distribution/).


#### Optional: Installing nteract

On local systems, you can also install and use the [nteract](https://nteract.io/) deskop applicaton to run Jupyter notebooks (instead of using a Jupyter server). nteract should detect the Jupyter Julia kernel that will be installed when you instantiate the LEGEND Julia environment (see below).


#### Environment variables

You may want/need to set the following environment variables:

* `$PATH`: Include the Julia `bin`-directory in your binary search path, see above.
If you intend to use Jupyter, you will probably want to include the directory containing the `jupyter` binary to your `PATH` as well.


* [`$JULIA_NUM_THREADS`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_THREADS-1): Number of threads to use for Julia multi-threading

* [`$JULIA_DEPOT_PATH`](https://julialang.github.io/Pkg.jl/v1/glossary/) and [`JULIA_PKG_DEVDIR`](https://julialang.github.io/Pkg.jl/v1/managing-packages/#Developing-packages-1): If you want Julia to install packages in another location than `$HOME/.julia`.

See the Julia manual for a description of [other Julia-specific environment variables](https://docs.julialang.org/en/v1/manual/environment-variables/).


## Setting up the tutorial and installing the required Julia packages

Download this tutorial via `Git` and change into the "legend-julia-tutorial" directory:

```shell
git clone https://github.com/legend-exp/legend-julia-tutorial.git
cd legend-julia-tutorial
```

Julia has a very powerful [package management system](https://julialang.github.io/Pkg.jl/v1/) that allows for using different versions of packages for different projects, layered package environments, etc. Run the shell command

```
julia --project=. -e 'using Pkg; pkg"instantiate; precompile"'
```

to instantiate the [Julia project environment](https://docs.julialang.org/en/v1/manual/code-loading/#Project-environments-1) defined by the files "Project.toml" and "Manifest.toml" in the "legend-julia-tutorial" directory.

Optional: To make this environment available generally, independent of your current directory, create a directory "$HOME/user/.julia/environments/legend" and copy both "Project.toml" and "Manifest.toml" into that directory. Afterwards, you'll be able to activate the "legend" environment via [`activate --shared legend`](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.activate) on the Julia package management console (which you can enter by pressing `]` in Julia).

Optional: Of course you may also istall the required packages (listed in "Project.toml") into your default julia environment (located in "$HOME/user/.julia/environments/v1.4"), the packages in the default environment are always available in Julia.

The tutorial is based on the included Markdown file with embedded Julia code "legend-julia-software-tutorial.md", from which a Jupyter notebook "legend-julia-software-tutorial.ipynb" and a plain Julia script "legend-julia-software-tutorial.jl" can be generated. To generate all tutorial files, run

```shell
julia --project=. make.jl
```


## Running the tutorial

The tutorial is offered in several variants (see above).

Note: To activate Julia's multi-threading support, set the environment variable [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1.0/manual/environment-variables/#JULIA_NUM_THREADS-1) *before* starting Julia or Jupyter.


### Using the Jupyter tutorial notebook

The Jupyter notebook version of the tutorial is probably the best starting point for most users.

If you do *not* have a Jupyter installation on your `$PATH`, you may want to start [Jupyter via Julia](https://julialang.github.io/IJulia.jl/stable/manual/running/) or (on a desktop system) use [nteract](https://nteract.io/).

If you *do* have a Jupyter installation on your `$PATH` (preferred), you can just usually start a [Jupyter notebook server](https://jupyter-notebook.readthedocs.io/en/stable/) using

```shell
jupyter notebook
```

When using a Jupyter installation on your local system, your web browser will usually be started automatically and be pointed to the Jupyter notebook server instance. However, when using a software container or starting jupyter on a remote system with SSH port forwarding (and in some other cases), Jupyter will complain that it can't start the web browser. In these cases, run

```shell
jupyter notebook --no-browser
```

Jupyter will print the URL to point your web browser too, this URL should include an authorization token (unless you configured Jupyter for [password-based access](https://jupyter-notebook.readthedocs.io/en/stable/security.html#alternatives-to-token-authentication)).

Depending on where and how you run Jupyter - especially if you run in a Docker container - you may need to specify a non-standard port number and/or IP address to bind to, or allow Jupyter to run in a root user account. In such cases, additional options will be required, e.g.:

```shell
jupyter notebook --no-browser --ip 0.0.0.0 --port 8888 --allow-root
```

On the Jupyter web page, open the notebook "legend-julia-software-tutorial.ipynb", and on the notebook page, choose "Run all cells" from the menu at the top of the page.


### Using the Markdown tutorial document with embedded Julia code

Note: We haven't tested this variant as well as using Jupyter, use at your own risk. In some circumstances, Weave seems to produce all plots but doesn't terminate and fails to produce a final output document.

The file "legend-julia-software-tutorial.jmd" is a human-readable Markdown document with embedded Julia code sections. You can use the Julia package [Weave.jl](https://github.com/mpastell/Weave.jl) to run the embedded code and generate a report (with embedded plots) from it in various formats (PDF, HTML, LaTeX, etc.). The result is similar to a Jupyter notebook converted to such an output format.

Start Julia (with the tutorial environment)

```shell
julia --project=.
```

and (on the Julia console) run

```julia
julia> using Weave
julia> weave("legend-julia-software-tutorial.jmd", doctype="md2html")
```

You can list the available output formats (e.g. "md2html", "md2pdf", etc.) via

```julia
julia> Weave.list_out_formats()
```

Some output formats will require additional software (e.g. certain LaTeX packages) to be installed.


### Using the Julia tutorial script

You can also run the script "legend-julia-software-tutorial.jl" directly. However, plots will constantly be replaced by the next plot and no output will be saved. The Julia script is more useful as a starting point for advanced users who want to start developing their own scripts.


### Building a custom Julia LEGEND system image

The LEGEND Julia packages and their dependencies constitute a large code base, using them the first time in a new Julia session takes a while (each time). To reduce this startup latency (due to package loading and code-generation
time), you can build a custom Julia system image that includes almost all of the packages used in the LEGEND Julia tutorial via [PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/dev/).

Run

```shell
julia --project=. build_sysimage.jl
```

to build the custom Julia LEGEND system image and

```shell
julia --project="/path/to/this/legend-julia-tutorial" --sysimage="/path/to/legend-julia-tutorial/JuliaSysimage.so"
```

to use it. Note: The file name of the system image file is OS-dependent: on Linux it is "JuliaSysimage.so", on OS-X it is "JuliaSysimage.dylib", and on Windows it is "JuliaSysimage.dll".

Also note that using a custom Julia system image freezes all included packages and all their transitive dependencies to the package version used when generating the image. While the custom system image is used, none of these Julia packages can be updated. The system image will also only work for your current Julia version.

If you activate the "legend-julia-tutorial" project/environment in the [Julia plugin for Visual Studio Code](https://www.julia-vscode.org/), you may want to enable the `"julia.useCustomSysimage"` option to [use the custom system image automatically](https://www.julia-vscode.org/docs/stable/userguide/compilesysimage/).


## Learning (more about) Julia

If you're interesting in learning Julia, or just learning more about Julia, the [Julia website](https://julialang.org/) provides many [links to introductory videos and written tutorials](https://julialang.org/learning/), e.g. ["Intro to Julia"](https://www.youtube.com/watch?v=fMa1qSg_LxA),
["A Deep Introduction to Julia for Data Science and Scientific Computing"](http://ucidatascienceinitiative.github.io/IntroToJulia/)
and ["The Fast Track to Julia 1.0"](https://juliadocs.github.io/Julia-Cheat-Sheet/)

The in-depth article [Why Numba and Cython are not substitutes for Julia](http://www.stochasticlifestyle.com/why-numba-and-cython-are-not-substitutes-for-julia/) explains how Julia addresses several fundamental challenges inherent to scientific computing.
