using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/bge.jl")

# Scenarios

for rcp in ["RCP4.5", "RCP3-PD/2.6", "RCP6", "NP-Base", "CP-Base", "1.5-Base"]
    for TP in ["NoTPs", "NoOMH"]
        if TP == "NoOMH"
            global model = full_model(;
                                      rcp = rcp, # Concatenate correct scenario-variant name
                                      ssp = "SSP2",
                                      #co2 = "Expectation",
                                      #ch4 = "default",
                                      #warming = "Best fit multi-model mean",
                                      tdamage = "pointestimate",
                                      slrdamage = "mode",
                                      saf = "Distribution mean",
                                      interaction = true,
                                      pcf = "Fit of Hope and Schaefer (2016)",
                                      omh = false,
                                      amaz = "Cai et al. central value",
                                      gis = "Nordhaus central value",
                                      ais = "AIS",
                                      ism = "Value",
                                      amoc = "IPSL",
                                      nonmarketdamage = true)
        else
            global model = full_model(;
                                      rcp = rcp, # Concatenate correct scenario-variant name
                                      ssp = "SSP2",
                                      #co2 = "Expectation",
                                      #ch4 = "default",
                                      #warming = "Best fit multi-model mean",
                                      tdamage = "pointestimate",
                                      slrdamage = "mode",
                                      saf = "Distribution mean",
                                      interaction = false,
                                      pcf = false,
                                      omh = false,
                                      amaz = false,
                                      gis = false,
                                      ais = false,
                                      ism = false,
                                      amoc = false,
                                      nonmarketdamage = true)
        end

        println("$rcp SSP2 $TP")

        myupdate_param!(model, :Consumption, :damagepersist, 0.25)

        Random.seed!(26052023)

        ### Run the model so we can run scripts
        run(model)

        ### Run the model in MC mode
        if TP == "NoOMH"
            results = sim_full(model, 1000,
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
                               false; # prtp
                               save_rvs=false)
        else
            results = sim_full(model, 1000,
                               "none", # PCF
                               "none", # AMAZ
                               "none", # GIS
                               "none", # WAIS
                               "Distribution", # SAF
                               false, # ais_used
                               false, # ism_used
                               false, # omh_used
                               false, # amoc_used
                               false, # persist
                               false, # emuc
                               false; # prtp
                               save_rvs=false)
        end
        run(model) # model is overwritten in some cases

        if rcp == "RCP3-PD/2.6"
            rcpfile = "RCP2.6"
        else
            rcpfile = rcp
        end

        #Export country-level damages
        df = simdataframe(model, results, :TotalDamages, :total_damages_percap_peryear_percent)
        CSV.write("../results/bytimexcountry-SSP2-$rcpfile-$TP-damages.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

        #Export country-level temperatures
        df = simdataframe(model, results, :PatternScaling, :T_country)
        CSV.write("../results/bytimexcountry-SSP2-$rcpfile-$TP-temps.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

        df = simdataframe(model, results, :TemperatureConverter, :T_AT)
        CSV.write("../results/bytime-SSP2-$rcpfile-$TP-gwarm.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])
    end
end
