using CSV
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")

## model = full_model(rcp="RCP4.5", ssp="SSP2", nonmarketdamage=true)
model = full_model(rcp="RCP8.5", ssp="SSP5", nonmarketdamage=true)
myupdate_param!(model, :Consumption, :damagepersist, 0.25)
run(model)

results = sim_full(model, 1000,
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
                   false; # prtp
                   save_rvs=true)

df = simdataframe(model, results, :TotalDamages, :total_damages_global_peryear_percent)
CSV.write("../results/bytime-totalloss-ssp585.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

df = simdataframe(model, results, :TotalDamages, :total_damages_percap_peryear_percent)
CSV.write("../results/bytimexcountry-totalloss-ssp585.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])



