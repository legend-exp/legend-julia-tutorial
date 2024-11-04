# This software is licensed under the MIT "Expat" License.

import Pkg


# Activate tutorial environment and generate Jupyter notebook

Pkg.activate(@__DIR__)
Pkg.instantiate() # Need to run this only once

import Literate

Literate.notebook("legend-julia-software-tutorial.jl", ".", execute = false, name = "legend-julia-software-tutorial", credit = true)
