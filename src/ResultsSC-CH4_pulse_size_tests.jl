##This file produces all May 2023 results for the AERE talk.

using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")
include("../src/bge.jl")


# Scenarios
for (x,y) in [("CP-", "SSP2"), ("NP-", "SSP3"), ("1.5-", "SSP1")]
    for z in ["Base"#=, "GMP", "GMP-LowCH4", "GMP-HighCH4"=#]

        # TP configurations
        for TP in ["NoTPs", "TPs", "NoOMH"]
            if TP == "TPs"
                global model = full_model(;
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
                                          co2 = "Expectation",
                                          ch4 = "default",
                                          warming = "Best fit multi-model mean",
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
                                          nonmarketdamage = true)
            elseif TP == "NoOMH"
                global model = full_model(;
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
                                          co2 = "Expectation",
                                          ch4 = "default",
                                          warming = "Best fit multi-model mean",
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
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
                                          co2 = "Expectation",
                                          ch4 = "default",
                                          warming = "Best fit multi-model mean",
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

            for persistence in ["high", "default"]
                println("$x$z $y $TP $persistence")

                if persistence == "high"
                    myupdate_param!(model, :Consumption, :damagepersist, 0.25)
                else
                    myupdate_param!(model, :Consumption, :damagepersist, 0.5)
                end

                Random.seed!(26052023)

                ### Run the model so we can run scripts
                run(model)

                function get_nonscc_results(inst, draws, ii; save_rvs)
                    mcres = getsim_full(inst, draws, ii; save_rvs=save_rvs)
                    bgeres = calculate_bge(inst)
                    mcres[:bge] = bgeres

                    mcres
                end

                ### Run the model in MC mode
                if TP == "TPs"
                    results = sim_full(model, 50,
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
                                       save_rvs=true,
                                       getsim=get_nonscc_results)
                elseif TP == "NoOMH"
                    results = sim_full(model, 50,
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
                    save_rvs=true,
                    getsim=get_nonscc_results)
                else
                    results = sim_full(model, 50,
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
                                       save_rvs=true,
                                       getsim=get_nonscc_results)
                end

                #=
                bgeresults = DataFrame(mc=Int64[], country=String[], bge=Float64[])
                for mc in 1:length(results[:other])
                    bgeres = results[:other][mc][:bge]
                    bgeres[!, :mc] .= mc
                    bgeresults = vcat(bgeresults, bgeres)
                end

                CSV.write("../results/bge-$x$z-$y-$TP-$persistence.csv", bgeresults)

                df = simdataframe(model, results, :SLRModel, :SLR)
                for (comp, var) in [(:TotalDamages, :total_damages_global_peryear_percent), (:TemperatureConverter, :T_AT)]
                    subdf = simdataframe(model, results, comp, var)
                    df[!, names(subdf)[2]] = subdf[!, 2]
                end
                CSV.write("../results/bytime-$x$z-$y-$TP-$persistence.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

                df = simdataframe(model, results, :TotalDamages, :total_damages_percap_peryear_percent)
                CSV.write("../results/bytimexcountry-$x$z-$y-$TP-$persistence.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

                # Export country-level temperatures
                df = simdataframe(model, results, :PatternScaling, :T_country)
                CSV.write("../results/bytimexcountry2-$x$z-$y-$TP-$persistence.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])
                =#

                ### Calculate the SC-CO2 in MC mode
                ## Miniloop over pulse year
                sccresults = DataFrame(pulse_size=Float64[], scch4=Float64[])
                for yy in [0.36, 0.24, 0.12, 0.06, 0.04, 0.01, 0.005, 0.001, 0.0001] # 360,000 kt CH4 to 100 kt CH4
                    if TP == "TPs"
                        subscch4 = calculate_scch4_full_mc(model,
                                                        50, # MC reps
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
                                                        2020, # pulse year
                                                        yy, # pulse size
                                                        1.5) # EMUC
                    elseif TP=="NoOMH"
                        subscch4 = calculate_scch4_full_mc(model,
                                                        50, # MC reps
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
                                                        yy, # pulse size
                                                        1.5) # EMUC

                    else
                        subscch4 = calculate_scch4_full_mc(model,
                                                        50, # MC reps
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
                                                        false, # prtp
                                                        2020, # pulse year
                                                        yy, # pulse size
                                                        1.5) # EMUC
                    end
                    scch4=subscch4[:other]
                    sccresults = vcat(sccresults, DataFrame(pulse_size=yy, scch4=scch4))
                end

                CSV.write("../results/sccs-$x$z-$y-$TP-$persistence.csv", sccresults)
            end
        end
    end
end




##Results post Julia
#-Truncate runs as in PNAS paper
#-Write Stata script to make pretty graphs and maps


#=Monte Carlo to do post AERE
#-Ensure individual runs are comparable within MC draw
=#
