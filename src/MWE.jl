cd("C:\\Users\\Thomas\\Documents\\GitHub\\META\\src")

using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")
include("../src/bge.jl")

calc_nationals = true

global model = full_model(;
                                          rcp = "CP-Base", # Concatenate correct scenario-variant name
                                          ssp = "SSP2",
                                          #co2 = "Expectation",
                                          #ch4 = "default",
                                          #warming = "Best fit multi-model mean",
                                          tdamage = "pointestimate",
                                          slrdamage = "mode",
                                          saf = "Distribution mean",
                                          interaction = true,
                                          pcf = "Fit of Hope and Schaefer (2016)",
                                          omh = "Whiteman et al. beta 20 years",
                                          amaz = "Cai et al. central value",
                                          gis = "Nordhaus central value",
                                          ais = "AIS",
                                          ism = "Value",
                                          amoc = "IPSL",
                                          nonmarketdamage = false)#true) SWITCH NON-MARKET DAMAGE BACK ON
            
           

                    myupdate_param!(model, :Consumption, :damagepersist, 0.25)

                    myupdate_param!(model, :Consumption, :damagepersist, 0.5)


                Random.seed!(26052023)

                ### Run the model so we can run scripts
                run(model)

### Run the model in MC mode
    results = sim_full(model, 10,
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

run(model) # model is overwritten in some cases

calculate_scc_full_mc(model,
                                                        10, # MC reps
                                                        "Fit of Hope and Schaefer (2016)", # PCF
                                                        "Cai et al. central value", # AMAZ
                                                        "Nordhaus central value", # GIS
                                                        "none", # WAIS
                                                        "Distribution", # SAF
                                                        true, # ais_used
                                                        true, # ism_used
                                                        false, # omh_used
                                                        true, # amoc_used
                                                        false, # persist
                                                        false, # emuc
                                                        false, # prtp
                                                        2020, # pulse year
                                                        10.0, # pulse size
                                                        1.02; calc_nationals=calc_nationals) # EMUC
