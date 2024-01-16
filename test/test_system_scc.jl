using Test
include("../src/MimiMETA.jl")
include("../src/scc.jl")

model = full_model(rcp="RCP4.5", ssp="SSP2")
scc1 = calculate_scc(model, 2020, 1.0, 1.5)
sccs = calculate_scc_full_mc(model, 10,
                             "Fit of Hope and Schaefer (2016)", # PCF
                             "Cai et al. central value", # AMAZ
                             "Nordhaus central value", # GIS
                             "none", # WAIS
                             "Distribution", # SAF
                             true, # ais_used
                             true, # ism_used
                             true, # omh_used
                             true, # amoc_used
                             false, # persist
                             false, # emuc
                             false, # prtp
                             2020, 10., 1.5)
df = simdataframe(model, sccs, :other, :*)
scc2 = mean(df.scco2[df.country .== "global"])

@test scc1 != scc2
