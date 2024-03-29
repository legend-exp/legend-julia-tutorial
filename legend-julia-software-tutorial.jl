# This tutorial is licensed under the MIT License (MIT).

## Ensure that the right Julia project environment is active:

import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate() # Need to run this only once
basename(dirname(Pkg.project().path))

#-

## Load required Julia packages:

using Plots

using ArraysOfArrays, StaticArrays, Tables, TypedTables
using Statistics, Random, Distributions, StatsBase
using Unitful
import HDF5

using SolidStateDetectors
using RadiationSpectra
using RadiationDetectorSignals
using RadiationDetectorSignals: group_by_evtno, ungroup_by_evtno, group_by_evtno_and_detno
using LegendDataTypes
using LegendHDF5IO: readdata, writedata
using LegendTextIO

# <h1 style="text-align: center">
#     LEGEND Software Stack Tutorial in <br/>
#     <img alt="Julia" src="images/logos/julia-logo.svg" style="height: 4em; display: inline-block; margin: 1em;"/>
#     <img alt="Julia" src="images/logos/ssd_logo.svg" style="height: 4em; display: inline-block; margin: 1em;"/>
# </h1>
#
# <p style="text-align: center">
#     Felix&nbsp;Hagemann&nbsp;&lang;<a href="mailto:hagemann@mpp.mpg.de" target="_blank">hagemann@mpp.mpg.de</a>&rang;,
#     Lukas&nbsp;Hauertmann&nbsp;&lang;<a href="mailto:lhauert@mpp.mpg.de" target="_blank">lhauert@mpp.mpg.de</a>&rang;,
#     David&nbsp;Hervas&nbsp;Aguilar&nbsp;&lang;<a href="mailto:hervasa2@mpp.mpg.de" target="_blank">hervasa2@mpp.mpg.de</a>&rang;,
#     Oliver&nbsp;Schulz&nbsp;&lang;<a href="mailto:oschulz@mpp.mpg.de" target="_blank">oschulz@mpp.mpg.de</a>&rang;,
#     Martin&nbsp;Schuster&nbsp;&lang;<a href="mailto:schuster@mpp.mpg.de" target="_blank">schuster@mpp.mpg.de</a>&rang;,
#     Anna&nbsp;Julia&nbsp;Zsigmond&nbsp;&lang;<a href="azsigmon@mpp.mpg.de" target="_blank">azsigmon@mpp.mpg.de</a>&rang;
# </p>
#
# <p style="text-align: center">
#     SolidStateDetectors.jl (SSD)<br>
#     <a href="https://juliaphysics.github.io/SolidStateDetectors.jl/stable/" target="_blank">Documentation</a><br> 
#     <a href="https://github.com/JuliaPhysics/SolidStateDetectors.jl" target="_blank">GitHub</a><br> 
#     <a href="https://iopscience.iop.org/article/10.1088/1748-0221/16/08/P08007" target="_blank">Paper</a>
# </p>
# <div style="margin-top:0.0em">
#     <p style="text-align: center">
#         <img alt="LEGEND Logo" src="images/logos/legend-logo.svg" style="height: 20em; display: inline-block; margin: 0em;"/>
#     </p>
# </div>
#
# <p>See <a href="README.md">README.md</a> for instructions.</p>
#
# ## Calculation of detector potentials and fields
#
# ### Detector definition
#
# First, load a detector definition - here, an inverted-coaxial example detector design:

detector_config_filename = SSD_examples[:InvertedCoax]
T = Float32 # Optional; Default is Float32, but works with Float64 as well
sim = Simulation{T}(detector_config_filename)
plot(sim.detector, size = (700, 700))

# One can also have a look at how the initial conditions look like on the grid (it starts with a very coarse grid):
#
# This is optional. Its only to have a look at the initial state. 
# For example, if you want to check if you specified the detector 
# geometry correctly in your configuration file.
apply_initial_state!(sim, ElectricPotential)
plot(
    plot(sim.electric_potential), # initial electric potential (boundary conditions)
    plot(sim.point_types), # map of different point types: fixed point / inside or outside detector volume / depleted/undepleted
    plot(sim.q_eff_imp), # effective charge density distribution
    plot(sim.ϵ_r), # dielectric distribution
    layout = (1, 4), size = (1600, 500)
)

# Next, calculate the electric potential:

calculate_electric_potential!(sim, convergence_limit = 1e-6, refinement_limits = [0.2, 0.1, 0.05, 0.01])

#-

plot(
    plot(sim.electric_potential, φ = 20), # initial electric potential (boundary conditions)
    plot(sim.point_types), # map of different point types: fixed point / inside or outside detector volume / depleted/undepleted
    plot(sim.q_eff_imp), # effective charge density distribution
    plot(sim.ϵ_r), # dielectric distribution
    layout = (1, 4), size = (1600, 500)
)

# SolidStateDetectors.jl supports active (i.e. depleted) volume calculation:

get_active_volume(sim.point_types) # approximation (sum of the volume of cells marked as depleted)

# ### Partially depleted detectors
#
# SolidStateDetectors.jl can also calculate the electric potential of a partially depleted detector:

sim_undep = deepcopy(sim)
sim_undep.detector = SolidStateDetector(sim_undep.detector, contact_id = 2, contact_potential = 500); # V  <-- Bias Voltage of Mantle

calculate_electric_potential!( sim_undep,
                               depletion_handling = true,
                               convergence_limit = 1e-6,
                               refinement_limits = [0.2, 0.1, 0.05, 0.03],
                               verbose = false)

plot(
    plot(sim_undep.electric_potential),
    plot(sim_undep.point_types),
    layout = (1, 2), size = (800, 700)
)

#-

println("Depleted:   ", get_active_volume(sim.point_types))
println("Undepleted: ", get_active_volume(sim_undep.point_types));

# ### Electric field calculation
#
# Calculate the electric field of the fully depleted detector, given the already calculated electric potential:

calculate_electric_field!(sim, n_points_in_φ = 72)
calculate_electric_field!(sim_undep, n_points_in_φ = 72)

#-

plot(sim.electric_field, full_det = true, φ = 0.0, size = (700, 700))
plot_electric_fieldlines!(sim, full_det = true, φ = 0.0)

# ### Weighting potential calculation
#
# We need weighting potentials to simulate the detector charge signal induced by drifting charges. We'll calculate the weighting potential for the point contact and the outer shell of the detector:

for contact in sim.detector.contacts
    calculate_weighting_potential!(sim, contact.id, refinement_limits = [0.2, 0.1, 0.05, 0.01], n_points_in_φ = 2, verbose = false)
end

#-

plot(  
    plot(sim.weighting_potentials[1]),
    plot(sim.weighting_potentials[2]),
    size = (900, 700)
)

# ### Detector capacitance
#
# After the weighting potentials are calculated, one can determine the detector capacitance matrix:

calculate_capacitance_matrix(sim)

# # Drift and waveform simulation
#
# Given the electric field and a charge drift model, the charge drift can be simulated:

charge_drift_model = ADLChargeDriftModel()
sim.detector = SolidStateDetector(sim.detector, charge_drift_model);

# Now, let's create an "random" (multisite) event:

starting_positions = [ CylindricalPoint{T}( 0.020, deg2rad(10), 0.015 ),
                       CylindricalPoint{T}( 0.015, deg2rad(20), 0.045 ),
                       CylindricalPoint{T}( 0.022, deg2rad(35), 0.025 ) ]
energy_depos = T[1460, 609, 1000] * u"keV" # are needed later in the signal generation

evt = Event(starting_positions, energy_depos);

#-

simulate!(evt, sim, Δt = 5u"ns")

#-

plot(sim.detector, size = (700, 700))
plot!(evt.drift_paths)

#-

p_pc_signal = plot( evt.waveforms[1], lw = 1.5, xlims = (0, 1000), xlabel = "Time", ylabel = "Charge", 
                    unitformat = :slash, legend = false, tickfontsize = 12, guidefontsize = 14)

# # I/O
#
# The package offers a conversion of all the calculated fields to `NamedTuple`s which allows for saving and loading them into HDF5 files via the [LegendHDF5IO.jl](https://github.com/legend-exp/LegendHDF5IO.jl) package:

sim

#-

filename = "cache/inverted_coax_simulation.h5f"
if !ispath(dirname(filename)) mkpath(dirname(filename)) end
ssd_write(filename, sim)

#-

sim = ssd_read(filename, Simulation);

# # Quick simulation
#
# All the above steps, which offer more fine control over the individual steps, can be done with one function, `simulate!`. This can be useful if one just want to quickly test the config file for a new detector.

quick_sim = Simulation{T}(detector_config_filename)
simulate!(quick_sim);
plot( 
    plot(quick_sim.electric_potential),
    plot(quick_sim.weighting_potentials[1]),
    plot(quick_sim.weighting_potentials[2]),
    size = (1200, 500), layout = (1, 3)
)

# ## Waveform generation for Geant4 MC events
#
# Let's read in some Monte-Carlo events (produced by Geant4). We'll either read from Geant4 CSV and cache the result as HDF5, or read directly from HDF5 if already available:

mctruth_filename_csv = joinpath("data", "dual-invcoax-mctruth.csv")
mctruth_filename_hdf5 = joinpath("cache", "dual-invcoax-mctruth.h5")
if isfile(mctruth_filename_hdf5)
    println("Reading MC events from HDF5.")
    mc_events = HDF5.h5open(mctruth_filename_hdf5, "r") do input
        readdata(input, "mctruth")
    end
else
    println("Reading MC events from Geant4-CSV.")
    mc_events = open(read, mctruth_filename_csv, Geant4CSVInput)
    mkpath(dirname(mctruth_filename_hdf5))
    println("Writing MC events to HDF5.")
    HDF5.h5open(mctruth_filename_hdf5, "w") do output
        writedata(output, "mctruth", mc_events)
    end
end

# Producing pulse shapes from raw MC events is wasteful, it's more efficient to cluster detectors hits (within a small radius) first:

println("$(sum(length.(mc_events.edep))) hits before clustering")
mc_events_clustered = @time SolidStateDetectors.cluster_detector_hits(mc_events, 0.2u"mm")
println("$(sum(length.(mc_events_clustered.edep))) hits after clustering")

# Table of MC events is of type `DetectorHitEvents`:

typeof(mc_events_clustered) <: DetectorHitEvents

# We have a plotting recipe for `DetectorHitEvents`:

plot(mc_events_clustered)

# Waveform generation has to be per detector. Let's reshuffle the detector hits, grouping by event number and detector:

hits = ungroup_by_evtno(mc_events_clustered)
mc_events_per_det = group_by_evtno_and_detno(hits)

# The hits are now grouped by event number, but separately for each detector, and sorted by detector number:

issorted(mc_events_per_det.detno)

# This makes it easy to group them by detector number ...

mc_events_by_det = Table(consgroupedview(mc_events_per_det.detno, Tables.columns(mc_events_per_det)))

# ... and get all events for detector 1 in one chunk:

mc_events_det1 = Table(mc_events_by_det[1])

#-

plot(mc_events_det1)

# Raw MC events have a very narrow line width:

stephist(ustrip.(sum.(mc_events_det1.edep)), bins = 2600:0.1:2625, yscale = :log10)

# Let's make things more realistic by adding Fano noise:

Random.seed!(123) # only for testing 
det_material = sim.detector.semiconductor.material
mc_events_fnoise = add_fano_noise(mc_events_det1, det_material.E_ionisation, det_material.f_fano)
stephist(ustrip.(sum.(mc_events_det1.edep)), bins = 2600:0.1:2625, label = "raw MC edep", yscale = :log10)
stephist!(ustrip.(sum.(mc_events_fnoise.edep)), bins = 2600:0.1:2625, label = "with Fano noise", yscale = :log10)

# Also, we need to filter out the few events that, due to numerical effects, lie outside of the detector (the proper solution is to shift them slightly, this feature will be added in the future):

filtered_events = mc_events_fnoise[findall(pts -> all(p -> CartesianPoint(T.(ustrip.(uconvert.(u"m", p)))) in sim.detector, pts), mc_events_fnoise.pos)];
length(filtered_events)

#-

contact_charge_signals = simulate_waveforms(      
        filtered_events[1:2000],
        sim,
        max_nsteps = 4000, 
        Δt = 1u"ns", 
        verbose = false);

# Let's plot the first 100 generated waveforms:

waveforms = ArrayOfRDWaveforms(contact_charge_signals.waveform)
plot(waveforms[1:100], legend = false)

# One can also look individual events

evt1 = Event(filtered_events[1], T)
simulate!(evt1, sim, max_nsteps = 4000, Δt = 1u"ns", verbose = true)
p_drift = plot(sim.detector, label = "")
plot!(evt1.drift_paths)
p_signal = plot(evt1.waveforms[1], lw = 2, legend = false)
plot(p_drift, p_signal, size = (800, 400))

# We should add pre- and post-pulse baselines ...

waveforms_with_baseline_and_tail = ArrayOfRDWaveforms(SolidStateDetectors.add_baseline_and_extend_tail.(waveforms, 1200, 7000));
plot(waveforms_with_baseline_and_tail[1:10], legend = false)

# ... and also add some random values along the waveforms to simulate electronics noise in a simple fashion:

noisy_waveforms = ArrayOfRDWaveforms(
    map(
        wf -> RDWaveform(wf.time, wf.signal .+ rand!(Normal(0, 5e3), similar(ustrip.(wf.signal)))*unit(eltype(wf.signal))),
        waveforms_with_baseline_and_tail
    )
);

#-

plot(noisy_waveforms[1:100], legend = false, size = (900, 400))

# ## Waveform DSP
#
# Note: This section only demonstrates a very simple form of DSP for energy reconstruction, and will be extended in the near future.
#
# We can reconstruct a spectrum from the simulated waveforms, using the difference between the pre- and post-pulse baseline means as energy of the events (equivalent to a triangular shaping filter in a fixed position):

filter_length = 50
pre_pulse_mean = mean.(map(signal -> signal[1:filter_length], noisy_waveforms.signal))
pre_pulse_std = std.(map(signal -> signal[1:filter_length], noisy_waveforms.signal))
energy_threshold = mean(pre_pulse_std) * 3
post_pulse_mean = mean.(map(signal -> signal[end-filter_length:end], noisy_waveforms.signal))
E_reco = post_pulse_mean .- pre_pulse_mean
hist_uncal = fit(Histogram, ustrip.(filter(e -> e > energy_threshold, E_reco)), nbins = 1000)
plot(hist_uncal, st = :step, yscale = :log10, label="uncalibrated spectrum")

# ## Spectrum analysis
#
# The package [RadiationSpectra.jl](https://github.com/JuliaPhysics/RadiationSpectra.jl) provides a mechanism finding peaks in the spectrum. It can also run an auto-calibration of the spectrum, given a list of gamma lines that may be in the spectrum:

gamma_lines = [510.77, 583.191, 727.330, 860.564, 2614.533] 

h_cal, h_deconv, peakPositions, threshold, c, c_precal = RadiationSpectra.calibrate_spectrum(
    hist_uncal, gamma_lines)

p_uncal = plot(hist_uncal, st=:step, label = "uncalibrated spectrum", tickfontsize = 12, legendfontsize = 12)
p_deconv = plot(h_deconv, st=:step, label = "deconvolved spectrum", tickfontsize = 12, legendfontsize = 12)
hline!([threshold], label ="threshold")
p_cal = plot(h_cal, st = :step, yscale = :log10, label="calibrated spectrum", xlabel="E / keV", xlims=[0, 3000], xticks=0:500:3000, tickfontsize = 12, legendfontsize = 12, guidefontsize = 14)
vline!(gamma_lines, label="gamma lines: $(gamma_lines)")
plot(p_uncal, p_deconv, p_cal, layout = (3,1), size = (1000, 700))
