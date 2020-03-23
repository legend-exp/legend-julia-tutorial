# This script is licensed under the MIT License (MIT).

using Pkg
Pkg.activate(".")

using Weave

convert_doc("legend-julia-software-tutorial.jmd", "legend-julia-software-tutorial.jl")
convert_doc("legend-julia-software-tutorial.jmd", "legend-julia-software-tutorial.ipynb")
