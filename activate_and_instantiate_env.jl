using Pkg

Pkg.activate(".")
Pkg.instantiate()

pkg"""precompile"""
