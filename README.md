# LEGEND Julia Software Stack Tutorial

This tutorial demonstrates the LEGEND Julia software stack: It shows how to simulate an inverted-coaxial HPGe detector, how to generate detector waveforms based on Geant4 MC results, how to reconstruct an energy spectrum from the simulated pulses and how to perform an auto-calibration of the resulting spectrum.

Note: This is a work in progress, more functionality will be added over time. The LEGEND-related software packages used are still under very active development, so types and functions may change without notice. This tutorial will be updated regularly and adapted to API changes.


## Required Software

The tutorial requires [Jupyter](https://jupyter.org/). You may either use the LEGEND base software container image, or install Julia and Jupyter locally on your native OS. The installation instructions below are somewhat lengthy, to cover a variety of situations on Linux, OS-X and Windows, but the actual installation is typically quite simple.


### Using the LEGEND software container image

The easiest way to ensure that all required software is available is to use the [LEGEND base software container](https://github.com/legend-exp/legendexp_legend-base_img) (see the link for instructions).

When using the container image, you can skip the complete section "Installing Julia and Jupyter locally on your native OS".


### Installing Julia and Jupyter locally on your native OS

#### Installing Julia

Julia is easy to install:

* [Download Julia](https://julialang.org/downloads/).

* Extract the archive resp. run the installer.

* You may want to add the Julia "bin" directory to your `$PATH"`

Please use Julia v1.4 or later to run this tutorial.


#### Installing Jupyter

Julia can either use existing installations of Jupyter, or install it internally by creating an internal Conda installation within `$HOME/.julia/conda`. We recommend the first approach (especially using Anaconda), since Julia will otherwise have to download over 1 GB of software, the `$HOME/.julia` directory will grow very large, and you will need to start Jupyter in an indirect fashion via Julia (only to have Jupyter then start additional Julia instances as Jupyter kernels in return).

For details, see the [IJulia.jl](https://github.com/JuliaLang/IJulia.jl#installation), [PyCall.jl](https://github.com/JuliaPy/PyCall.jl#specifying-the-python-version) documentation (you should not need to if you follow the steps below).

On Linux, Julia (more specifically the Julia package [IJulia.jl](https://github.com/JuliaLang/IJulia.jl)) will by default try to use the Jupyter installation associated with the `jupyter` executable on your `$PATH`.

However, on OS-X and Windows, IJulia.jl by default always creates a Julia-internal Conda installation (see above), even if Jupyter is available (apparently broken Jupyter installations on these platforms caused frequent support requests).  In contrast to this default behavior, we recommend to use a standalone Jupyter installation on all OS platforms. Set the environment variables [`$JUPYTER`](https://github.com/JuliaLang/IJulia.jl#installation) to point to your Jupyter and Python executable to force Julia to use the existing installation.

We recommend that you install the [Anaconda](https://www.anaconda.com/) Python distribution, it includes Jupyter (it is of course possible to use non-Anaconda Jupyter installations instead).


#### Installing Anaconda

To install Anaconda

* [Download Anaconda](https://www.anaconda.com/distribution/).

* Run the installer

* Set the environment variables [`$JUPYTER`](https://github.com/JuliaLang/IJulia.jl#installation) and [`$PYTHON`](https://github.com/JuliaPy/PyCall.jl#specifying-the-python-version) to the full path of the Jupyter and Python executables (see above).

* Note: OS-X => v1.15 ("Catalina") by default uses the "zsh" shell instead of "bash". However, the Anaconda installer (at least in some versions) still seems to add add it's `$PATH` settings to "$HOME/.bash_profile", instead of "$HOME/.zshrc". You may have to copy the Anaconda-related section to the correct file.


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
julia --project=. --color=yes -e 'using Pkg; pkg"instantiate; precompile"'
```

to instantiate the [Julia project environment](https://docs.julialang.org/en/v1/manual/code-loading/#Project-environments-1) defined by the
files "Project.toml" and "Manifest.toml" in the "legend-julia-tutorial" directory.

Optional: To make this environment available generally, independent of your current directory, create a directory "$HOME/user/.julia/environments/legend" and copy both "Project.toml" and "Manifest.toml" into that directory. Afterwards, you'll be able to activate the "legend" environment via [`activate --shared legend`](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.activate) on the Julia package management console (which you can enter by pressing `]` in Julia).

Optional: Of course you may also istall the required packages (listed in "Project.toml") into your default julia environment (located in "$HOME/user/.julia/environments/v1.4"), the packages in the default environment are always available in Julia.

The tutorial is based on the included Markdown file with embedded Julia code "legend-julia-software-tutorial.md", from which a Jupyter notebook "legend-julia-software-tutorial.ipynb" and a plain Julia script "legend-julia-software-tutorial.jl" can be generated. To generate all tutorial files, run

```shell
julia --project=. make.jl
```

Instead of using the [`--project` command line option](https://docs.julialang.org/en/v1/manual/getting-started/), you can also set the [`$JULIA_PROJECT` environment variable](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_PROJECT-1):

```shell
export JULIA_PROJECT=`pwd`
julia make.jl
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


### Building a custom Julia LEGEND system image

The LEGEND Julia packages and their dependencies constitute a large code base,
using them the first time in a new Julia session takes a while (each time).
To reduce this startup latency (due to package loading and code-generation
time), you can build a custom Julia system image that includes almost all of
the packages used in the LEGEND Julia tutorial via
[PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/dev/).

Run

```shell
julia --project=. build_sysimage.jl
```

to build the custom Julia LEGEND system image and

```shell
julia --project="/path/to/this/legend-julia-tutorial" --sysimage="/path/to/legend-julia-tutorial/JuliaSysimage.so"
```

to use it. Note: The file name of the system image file is OS-dependent:
on Linux it is "JuliaSysimage.so", on OS-X it is "JuliaSysimage.dylib",
and on Windows it is "JuliaSysimage.dll".

Also note that using a custom Julia system image freezes all included packages
and all their transitive dependencies to the package version used when
generating the image. While the custom system image is used, none of these
Julia packages can be updated.

If you activate the "legend-julia-tutorial" project/environment in the
[Julia plugin for Visual Studio Code](https://www.julia-vscode.org/),
you may want to enable the `"julia.useCustomSysimage"` option to
[use the custom system image automatically](https://www.julia-vscode.org/docs/stable/userguide/compilesysimage/).


## Learning (more about) Julia

If you're interesting in learning Julia, or just learning more about Julia, the [Julia website](https://julialang.org/) provides many [links to introductory videos and written tutorials](https://julialang.org/learning/), e.g. ["Intro to Julia"](https://www.youtube.com/watch?v=fMa1qSg_LxA),
["A Deep Introduction to Julia for Data Science and Scientific Computing"](http://ucidatascienceinitiative.github.io/IntroToJulia/)
and ["The Fast Track to Julia 1.0"](https://juliadocs.github.io/Julia-Cheat-Sheet/)

Note: Try to avoid tutorials and books written for Julia v0.6 as there have been quite a few changes in the language in v1.0.

There are also a lot of interesting talk and tutorials on the [Julia YouTube Channel](https://www.youtube.com/user/JuliaLanguage). Have a look at the [talks at JuliaCon 2018](https://www.youtube.com/playlist?list=PLP8iPy9hna6Qsq5_-zrg0NTwqDSDYtfQB) to get an impression on the kinds of scientific applications Julia is being used for and why, e.g. ["Why Julia is the most suitable language for science"](https://youtu.be/7y-ahkUsIrY).

The in-depth article [Why Numba and Cython are not substitutes for Julia](http://www.stochasticlifestyle.com/why-numba-and-cython-are-not-substitutes-for-julia/) explains how Julia addresses several fundamental challenges inherent to scientific computing.

If you want to get an impression of the attention to detail so typical for Julia, watch ["0.1 vs 1//10: How numbers are compared"](https://youtu.be/CE1x130lYkA).
