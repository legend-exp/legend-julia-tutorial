# LEGEND Julia Software Stack Tutorial

This tutorial demonstrates the LEGEND Julia software stack: It shows how to simulate an inverted-coaxial HPGe detector, how to generate detector waveforms based on Geant4 MC results, how to reconstruct an energy spectrum from the simulated pulses and how to perform an auto-calibration of the resulting spectrum.

Note: This is a work in progress, more functionality will be added over time. The LEGEND-related software packages used are still under very active development, so types and functions may change without notice. This tutorial will be updated regularly and adapted to API changes.


## Required Software

The tutorial requires [Jupyter](https://jupyter.org/), [matplotlib/PyPlot](https://matplotlib.org/) and [HDF5](https://www.hdfgroup.org/) in addition to Julia. You may either use the LEGEND base software container image, or install Julia, Jupyter and PyPlot locally on your native OS. The installation instructions below are somewhat lengthy, to cover a variety of situations on Linux, OS-X and Windows, but the actual installation is typically quite simple.


### Using the LEGEND software container image

The easiest way to ensure that all required software is available is to use the [LEGEND base software container](https://github.com/legend-exp/legendexp_legend-base_img) (see the link for instructions).

When using the container image, you can skip the complete section "Installing Julia, Jupyter and PyPlot locally on your native OS".


### Installing Julia, Jupyter and PyPlot locally on your native OS

#### Installing Julia

Julia is easy to install:

* [Download Julia](https://julialang.org/downloads/).

* Extract the archive resp. run the installer.

* You may want to add the Julia "bin" directory to your `$PATH"`


#### Installing Jupyter and PyPlot

Julia can either use existing installations of Jupyter and PyPlot (OS native or [Anaconda](https://www.anaconda.com/)), or install both internally by creating an internal Conda installation within "$HOME/.julia/conda". We recommend the first approach (especially using Anaconda), since Julia will otherwise have to download over 1 GB of software, the "$HOME/.julia" directory will grow very large, and Jupyter will have to be started in an indirect fashion via Julia (to then start other Julia instances as Jupyter kernels in return).

For details, see the [PyCall.jl](https://github.com/JuliaPy/PyCall.jl#specifying-the-python-version), [IJulia.jl](https://github.com/JuliaLang/IJulia.jl#installation) and [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) documentation (you should not need to refer to that documentation if you follow the steps below).

On Linux, Julia (more specifically the Julia packages [IJulia.jl](https://github.com/JuliaLang/IJulia.jl), [PyCall.jl](https://github.com/JuliaPy/PyCall.jl), and [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl)) will by default try to use the matplotlib/PyPlot installation associated with the "python3" (resp. "python") executable on your "$PATH". Likewise, Julia will by default try to use the Jupyter installation associated with the "jupyter" executable on your "$PATH".

However, on OS-X and Windows, both IJulia.jl and PyCall.jl by default always create a Julia-internal Conda installation (see above), even if Jupyter and matplotlib/PyPlot are available (apparently broken Jupyter/Python installations on these platforms caused frequent support requests). 

In contrast to this default behavior, we recommend to force IJulia.jl and PyCall.jl to use an existing external Jupyter and Python installation on all OS platforms. Do to this, you need to set the environment variables `.$JUPYTER` and `$PYTHON`. Run the `julia system_check.jl` to verify that things are set up correctly.script (see below) does *not* follow these default. To install Jupyter and matplotlib/PyPlot we recommend that you install Anaconda (especially on on OS-X and Windows) before doing so, and to make sure the Python and Jupyter programs provided by Anaconda are on your `$PATH` (default on OS-X, installer option on Windows). As an additional benefit, you gain a complete standalone Python environment that can also be used for LEGEND Python projects like [pygamma](https://github.com/wisecg/pygama).


#### Installing Anaconda

To install Anaconda

* [Download Anaconda](https://www.anaconda.com/download/).

* Run the installer

* Either ensure that the programs "jupyter" and "python3" (resp. "python") are on your `$PATH` (manually on Linux, by default on OS-X, installer option on Windows), or manually set the environment variables "$JUPYTER" and "$PYTHON" to the full path of the programs (see above).


#### Installing HDF5

Julia bindings for HDF5 are provided by the package [HDF5.jl](https://github.com/JuliaIO/HDF5.jl), but HDF5.jl requires the HDF5 C-libraries to be installed.

On Linux, install the HD5 system package provided by your distribution. On OS-X, if Julia fails to automatically install HDF5 internally via [Homebrew.jl](https://github.com/JuliaPackaging/Homebrew.jl), install HDF5 manually via [Homebrew](https://brew.sh/). On Windows, HDF5.jl should automatically install a version of the HDF5 libraries internally.


## Setting up the tutorial and installation of required Julia packages

Download this tutorial via `Git`, then run the included Julia script "install_julia_packages.jl" to automatically install all required Julia packages:

```shell
git clone https://github.com/legend-exp/legend-julia-tutorial.git
cd legend-julia-tutorial
julia --color=yes activate_and_instantiate_env.jl
```

Julia has a very powerful [package management system](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html) that allows for using different versions of packages for different projects, layered package environments, etc. The above script will simply install all packages required for this tutorial into the Julia environment in this folder. The packages, and their specific versions, are specified in the `Project.toml` and `Manifest.toml` files. If you want to install the packages also to your main Julia environment execute the line `julia install_julia_packages.jl`.

The tutorial is based on the included Markdown file with embedded Julia code "legend-julia-software-tutorial.md", from which a Jupyter notebook "legend-julia-software-tutorial.ipynb" and a plain Julia script "legend-julia-software-tutorial.jl" can be generated. To generate all tutorial files, run

```shell
julia --project=. make.jl
```


## Running the tutorial

The tutorial is offered in several variants (see above).

Note: To activate Julia's multi-threading support, set the environment variable [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1.0/manual/environment-variables/#JULIA_NUM_THREADS-1) *before* starting Julia or Jupyter.


### Using the Jupyter tutorial notebook

This is probably the best starting point for most users. If you followed the installation instructions above, the command "jupyter" should be on your `$PATH`. Start a [Jupyter notebook server](https://jupyter-notebook.readthedocs.io/en/stable/) using

```shell
jupyter notebook
```

When using a local Jupyter installation, your web browser will usually be started automatically and be pointed to the Jupyter notebook server instance. However, when using a software container or starting jupyter on a remote system with SSH port forwarding (and in some other cases), Jupyter will complain that it can't start the web browser. In these cases, run

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


## Learning (more about) Julia

If you're interesting in learning Julia, or just learning more about Julia, the [Julia website](https://julialang.org/) provides many [links to introductory videos and written tutorials](https://julialang.org/learning/), e.g. ["Intro to Julia"](https://www.youtube.com/watch?v=fMa1qSg_LxA),
["A Deep Introduction to Julia for Data Science and Scientific Computing"](http://ucidatascienceinitiative.github.io/IntroToJulia/)
and ["The Fast Track to Julia 1.0"](https://juliadocs.github.io/Julia-Cheat-Sheet/)

Note: Try to avoid tutorials and books written for Julia v0.6 as there have been quite a few changes in the language in v1.0.

There are also a lot of interesting talk and tutorials on the [Julia YouTube Channel](https://www.youtube.com/user/JuliaLanguage). Have a look at the [talks at JuliaCon 2018](https://www.youtube.com/playlist?list=PLP8iPy9hna6Qsq5_-zrg0NTwqDSDYtfQB) to get an impression on the kinds of scientific applications Julia is being used for and why, e.g. ["Why Julia is the most suitable language for science"](https://youtu.be/7y-ahkUsIrY).

The in-depth article [Why Numba and Cython are not substitutes for Julia](http://www.stochasticlifestyle.com/why-numba-and-cython-are-not-substitutes-for-julia/) explains how Julia addresses several fundamental challenges inherent to scientific computing.

If you want to get an impression of the attention to detail so typical for Julia, watch ["0.1 vs 1//10: How numbers are compared"](https://youtu.be/CE1x130lYkA).
