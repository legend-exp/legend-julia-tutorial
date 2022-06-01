@info "Starting precompile exec."

using Distributions, LinearAlgebra, DensityInterface, InverseFunctions
using BAT, ValueShapes
import Cuba

prior = HierarchicalDistribution(
    NamedTupleDist(a = Normal(), b = Weibull(), c = 5)
) do x
    NamedTupleDist(y = Normal(x.a, x.b), z = MvNormal([1.3 0.5; 0.5 2.2]))
end
likelihood = logfuncdensity((x -> -norm(x)^2) ∘ inverse(varshape(prior)))
density = PosteriorDensity(likelihood, prior)

samples_mh = bat_sample(density, MCMCSampling(mcalg = MetropolisHastings(), nchains = 4, nsteps = 10^4, strict = false)).result

samples_hmc = bat_sample(density, MCMCSampling(mcalg = HamiltonianMC(), nchains = 4, nsteps = 10^4, strict = false)).result
@show sd = SampledDensity(density, samples_hmc)
@show ess = bat_eff_sample_size(samples_hmc)

integral_vegas = bat_integrate(density, VEGASIntegration(strict = false)).result


ENV["GKSwstype"] = "nul"
import Plots

for plt in (
    Plots.histogram(randn(1000)),
    Plots.stephist(randn(1000)),
    Plots.histogram2d(randn(1000), randn(1000)),
    Plots.scatter(randn(10), randn(10), randn(10)),
    Plots.scatter(randn(10), randn(10), randn(10)),
    Plots.plot(samples_mh),
    Plots.plot(samples_hmc),
)
    Plots.prepare_output(plt)
    precompile(display, (Plots.PlotsDisplay, typeof(plt)))

    show(IOBuffer(), MIME"image/png"(), plt)
    show(IOBuffer(), MIME"image/svg+xml"(), plt)
end

@info "Precompile exec finished."
