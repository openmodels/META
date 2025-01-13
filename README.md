# META 2021
The Model for Economic Tipping point Analysis

META 2021 is an advanced integrated assessment model (SC-IAM), designed as a model-based meta-analysis of the effects of tipping points on the social cost of carbon (SCC). The model simulates greenhouse gas emissions, temperature and sea-level rise, and market and non-market damages at the country level, and the effects of eight climate tipping points that have been studied in the climate economics literature.

META 2021 is introduced in; **Dietz, Rising, Stoerk, and Wagner (2021): "Economic impacts of tipping points in the climate system", PNAS, 118(34), e2103081118.** [https://doi.org/10.1073/pnas.2103081118]

Scientific documentation for the current version of META is available
as [a PDF](https://raw.githubusercontent.com/openmodels/META/master/docs.pdf).

See that paper and its supplementary information for further
details. Please cite the paper when using META in your research.

This version of the model is implemented in Mimi
[https://www.mimiframework.org/], an integrated assessment modeling
framework developed in Julia [https://julialang.org/]. The model code consistent with the Dietz et al. (2021) paper is available at https://github.com/openmodels/META-2021/, in both Excel and Mimi formats.

## Directories in the repository

The following directories are used for the Mimi model:
 - `data`: Input parameters and validation outputs (under
   `data/benchmark`).
 - `src`: The model code. The scripts directly contained in this directory
   support various types of analyses, with internal model code in
   subdirectories. Specifically, the model components are under
   `src/components` and additional functions are in `src/lib`.
 - `test`: Unit tests, for each component, for the system-wide
   results, and for the Monte Carlo system.
   
## Basic use cases
 
 Please note that all code is designed to be run with the working
 directory set to a subdirectory of the repository (e.g., `src` or you
 can create a subdirectory `analysis`). Installation time for META on a standard desktop computer should be in the hours, while the speed of results production depends on the number of Monte Carlo draws. Monte Carlo sample sizes of 1,000 likely take hours, while sample sizes of 10,000 and beyond likely take days to compute on a standard desktop computer.
 
### 1. Running the full deterministic model
 
 The full model is constructed using `full_model(...)`, defined in
 `src/MimiMETA.jl`. The `full_model` function can be called with no
 arguments, to use the default construction, or override the defaults
 with the following arguments:
 
  - `rcp`: Emissions scenario; one of RCP3-PD/2.6, RCP4.5 (default), RCP6, or RCP8.5.
  - `ssp`: Socioeconomic scenario; one of SSP1, SSP2 (default), SSP3, SSP4, SSP5.
  - `tdamage`: Temperature damages; one of none, distribution,
    pointestimate (default), low, or high.
  - `slrdamage`: Sea-level rise damages; one of none, distribution,
    mode (default), low, or high.
  - `nonmarketdamage`: Non-market damages; May be false (to not use,
    default) or true.
  - `saf`: Surface albedo feedback calibration; May be false (to not
    use) or Distribution mean (default)
  - `pcf`: Permafrost carbon feedback calibration; May be false (to not
    use) or one of Fit of Hope and Schaefer (2016), Kessler central
    value, Kessler 2.5%, Kessler 97.5%, Fit of Hope and Schaefer (2016)
    (default), or Fit of Yumashev et al. (2019).
  - `omh`: Ocean methane hydrates calibration; May be false (to not
    use) or one of Whiteman et al. beta 20 years (default), Whiteman
    et al. uniform 10 years, "Whiteman et al. triangular, mode 10%, 10
    years", Whiteman et al. beta 10 years, "Ceronsky et al. (2011),
    1.784GtCH4 per year, beta", "Ceronsky et al. (2011), 7.8GtCH4 per
    year, beta", "Ceronsky et al. (2011), 0.2GtCH4 per year, beta",
    Whiteman et al. beta 20 years, Whiteman et al. beta 30 years,
    Whiteman et al. uniform 20 years, or "Whiteman et al. triangular,
    mode 10%, 20 years".
  - `amaz`: Amazon dieback calibration; May be false (to not use) or
    one of Cai et al. central value (default), Cai et al. long, or Cai
    et al. short.
  - `gis`: Greenland icesheet calibration; May be false (to not use)
    or one of Nordhaus central value (default), Robinson, Non-linear
    equilibrium function, Ice/SLR low, or Ice/SLR high.
  - `ais`: (West) Antarctic icesheet calibration; May be "AIS"
    (default, based on Dietz & Koninx (2022)
    [https://www.nature.com/articles/s41467-022-33406-6]) or "WAIS"
    (as implemented in Dietz et al. (2022)) or "none" (not used).
  - `ism`: Indian summer monsoon calibration; May be false (to not
    use) or Value (default).
  - `amoc`: Atlantic meridional overturning circulation; May be false
    (to not use) or one of Hadley, BCM, IPSL (default), or HADCM.
  - `interaction`: Tipping point interactions; May be false (to not
    use) or true (default).

There is also a `base_model` function which includes only the
non-tipping-point calibration options.

A basic usage is as follows:

```
include("../src/MimiMETA.jl")
model = full_model(rcp="RCP4.5", ssp="SSP2")
run(model)
explore(model)
```

Other examples are shown in `test/test_system_tp.jl` (for the full
model) and `test/test_system_notp.jl` (for the no-tipping-point
model).

### 2. Running the full Monte Carlo model

To run the model in Monte Carlo mode, run `sim_full(...)`, which is
defined in `src/montecarlo.jl`, using a model with all the relevant
components.

The `sim_full` function takes the following parameters, all of which
must be provided:
 - `model`: A full Mimi model.
 - `trials`: The number of Monte Carlo simulations.
 - `pcf_calib`: May be "Kessler probabilistic" to draw stochastic
   parameters for the PCF model, or one of the options described in
   the deterministic use case.
 - `amazon_calib`: May be "Distribution" to draw stochastic parameters
   for the Amazon dieback model, or one of the options described in
   the deterministic use case.
 - `gis_calib`: May be "Distribution" to draw stochastic parameters
   for the GIS model, or one of the options described in
   the deterministic use case.
 - `wais_calib`: May be "Distribution" to draw stochastic parameters
   for the WAIS model, or one of the options described in the
   deterministic use case.
 - `saf_calib`: May be "Distribution" to draw stochastic parameters
   for the SAF model, or one of the options described in the
   deterministic use case.
 - `ais_used`: Set to true if the AIS component is included;
    otherwise false.
 - `ism_used`: Set to true if the ISM component is included;
    otherwise false.
 - `omh_used`: Set to true if the OMH component is included;
    otherwise false.
 - `amoc_used`: Set to true if the AMOC component is included;
    otherwise false.
 - `persist_dist`: May be true to draw the level of temperature
   damages persistance stochastically, or false.
 - `emuc_dist`: May be true to draw the level of elasticity of
   marginal utility stochastically, or false.
 - `prtp_dist`: May be true to draw the level of pure rate of time
   preference stochastically, or false.

There is also a `sim_base`, which includes just the non-tipping-point
parameters.

A basic usage is as follows:

```
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
model = full_model(rcp="RCP4.5", ssp="SSP2")
results = sim_full(100, "Fit of Hope and Schaefer (2016)", # PCF
               "Cai et al. central value", # AMAZ
               "Nordhaus central value", # GIS
               "none", # WAIS
               "Distribution", # SAF
			   true, # AIS
			   true, # ISM
			   true, # OMH
			   true, # AMOC
               false, # persit
               false, # emuc
               false) # prtp
```

Other examples are included in `test/test_montecarlo_tp.jl`.

### 3. Calculating the social cost of carbon

The `src/scc.jl` script includes functions that help with the
calculation of the SCC, using the infrastructure within Mimi.

The current standard method is `calculate_scc_mc` which takes the
following parameters (all given, in order):
 - `model`: A version of the META model.
 - `preset_fill`: A function to fill in parameters from a pre-computed
   Monte Carlo collection.
 - `maxrr`: The number of Monte Carlos to perform.
 - `pulse_year`: The year to add an additional pulse of CO2.
 - `pulse_size`: The number of Gt to add.
 - `emuc`: The elasticity of marginal utility to use.
 
A basic usage is:
 
```
include("../src/MimiMETA.jl")
include("../src/lib/presets.jl")
include("../src/scc.jl")
benchmark = CSV.read("../data/benchmark/ExcelMETA-alltp.csv", DataFrame)
model = full_model()
preset_fill(rr) = preset_fill_tp(model, benchmark, rr)
calculate_scc_mc(model, preset_fill, nrow(benchmark), 2020, 10., 1.5) # Runs 500 MC reps.
```
