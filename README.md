# LEGEND Julia Software Stack Tutorial

This tutorial demonstrates the LEGEND Julia software stack: It shows how to simulate an inverted-coaxial HPGe detector, how to generate detector waveforms based on Geant4 MC results, how to reconstruct an energy spectrum from the simulated pulses and how to perform an auto-calibration of the resulting spectrum.

Note: This is a work in progress, more functionality will be added over time. The LEGEND-related software packages used are still under very active development, so types and functions may change without notice. This tutorial will be updated regularly and adapted to API changes.

[![Documentation](https://img.shields.io/badge/docs-main-blue.svg)](https://legend-exp.github.io/legend-julia-tutorial/main)


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

We recommend using Julia v1.7 or later to run this tutorial.


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

The file "legend-julia-software-tutorial.jl" is Julia script with embedded Markdown text sections. The script "make.jl" uses the Julia package [Literate.jl](https://github.com/fredrikekre/Literate.jl) to convert this script into a Jupyter notebook "legend-julia-software-tutorial.ipynb" with code and text cells.

Do do so, run

```shell
julia --project=. make.jl
```

You may of course also run the script "legend-julia-software-tutorial.jl" directly. However, plots will constantly be replaced by the next plot and no output will be saved. The Julia script is more useful as a starting point for advanced users who want to start developing their own scripts.


## Running the tutorial

The tutorial is offered in several variants (see above).

Note: To activate Julia's multi-threading support, set the environment variable [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1.0/manual/environment-variables/#JULIA_NUM_THREADS-1) *before* starting Julia or Jupyter.


### Using the Jupyter tutorial notebook

The Jupyter notebook version of the tutorial is probably the best starting point for most users.

Running Julia in Jupyter requires the [IJulia Jupyter Julia kernel](https://github.com/JuliaLang/IJulia.jl). If you do *not* have added IJulia in your default environment (we recommend that you do), you can add IJulia to the "legend-julia-tutorial" project using

```shell
julia --project=. -e 'using Pkg; Pkg.add("IJulia")'
```

If you *do* have IJulia in your default environment then *don't* add it to "legend-julia-tutorial" as well.

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


## Learning (more about) Julia

If you're interesting in learning Julia, or just learning more about Julia, the [Julia website](https://julialang.org/) provides many [links to introductory videos and written tutorials](https://julialang.org/learning/), e.g. ["Intro to Julia"](https://www.youtube.com/watch?v=fMa1qSg_LxA),
["A Deep Introduction to Julia for Data Science and Scientific Computing"](http://ucidatascienceinitiative.github.io/IntroToJulia/)
and ["The Fast Track to Julia 1.0"](https://juliadocs.github.io/Julia-Cheat-Sheet/)

The in-depth article [Why Numba and Cython are not substitutes for Julia](http://www.stochasticlifestyle.com/why-numba-and-cython-are-not-substitutes-for-julia/) explains how Julia addresses several fundamental challenges inherent to scientific computing.
