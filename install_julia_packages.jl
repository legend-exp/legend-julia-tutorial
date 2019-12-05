# This script is licensed under the MIT License (MIT).

if !Sys.isunix() || Sys.isapple()
    for envvar_name in ["JUPYTER", "PYTHON"]
        if !haskey(ENV, envvar_name)
            @error "Please set environment variable $envvar_name, run \"julia system_check.jl\" for details."
            exit(1)
        end
    end
end

using Pkg

Pkg.add("ArraysOfArrays")
Pkg.add("BufferedStreams")
Pkg.add("CoordinateTransformations")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("DSP")
Pkg.add("ElasticArrays")
Pkg.add("FFTW")
Pkg.add("FillArrays")
Pkg.add("GPUArrays")
Pkg.add("HDF5")
Pkg.add("IJulia")
Pkg.add("Interact")
Pkg.add("LaTeXStrings")
Pkg.add("LsqFit")
Pkg.add("Measurements")
Pkg.add("Optim")
Pkg.add("ParallelProcessingTools")
Pkg.add("Plots")
Pkg.add("PyCall")
Pkg.add("PyPlot")
Pkg.add("RecipesBase")
Pkg.add("SolidStateDetectors")
Pkg.add("SpecialFunctions")
Pkg.add("SplitApplyCombine")
Pkg.add("StaticArrays")
Pkg.add("StatsBase")
Pkg.add("Tables")
Pkg.add("TypedTables")
Pkg.add("Unitful")
Pkg.add("UnsafeArrays")
Pkg.add("Weave")

Pkg.add(PackageSpec(url="https://github.com/JuliaPhysics/RadiationDetectorSignals.jl.git", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaPhysics/RadiationDetectorDSP.jl.git", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaPhysics/RadiationSpectra.jl.git", rev="BAT"))

Pkg.add(PackageSpec(url="https://github.com/legend-exp/LegendDataTypes.jl.git", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/legend-exp/LegendDSP.jl.git", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/legend-exp/LegendHDF5IO.jl.git", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/legend-exp/LegendTextIO.jl.git", rev="master"))

pkg"""precompile"""
