##This file produces all October 2023 results for our final draft for submission.

#=This file only works with a previous version of MimiFAIRv2 (Lisa and Frank changed some of their datastructures later to
improve speed, but as far as I understand no difference to the content.) To ensure the right version of MimiFAIRv2 is installed,
do the following steps:
-1 Don't update MimiFAIRv2 from your current version OR Remove current version
-2 Install MimiFAIRv2 at specific commit (https://stackoverflow.com/questions/47243088/how-to-use-julia-package-at-a-certain-commit)

Correct commit (Lisa 22 May 23 update to README.md): https://github.com/FrankErrickson/MimiFAIRv2.jl/tree/d07bb9995b26b4b5605cc38fa040226928799339

Code to use in pkg mode: add https://github.com/FrankErrickson/MimiFAIRv2.jl#d07bb9995b26b4b5605cc38fa040226928799339
=#

#Comment out if ran on different machine
cd("C:\\Users\\Thomas\\Documents\\GitHub\\META\\src")

using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")

calc_nationals = true

# Scenarios
for (x,y) in [("CP-", "SSP2")#=("NP-", "SSP3"), ("1.5-", "SSP1")=#]
    for z in ["Base"#=, "GMP", "GMP-LowCH4", "GMP-HighCH4"=#]

        # TP configurations
        for TP in [#="NoTPs","TPs",=#"NoOMH"]
            if TP == "TPs"
                global model = full_model(;
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
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
                                          nonmarketdamage = true)
            elseif TP == "NoOMH"
                global model = full_model(;
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
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
                                          rcp = x*z, # Concatenate correct scenario-variant name
                                          ssp = y,
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

            for persistence in ["high"#=, "default"=#]
                println("$x$z $y $TP $persistence")

                if persistence == "high"
                    myupdate_param!(model, :Consumption, :damagepersist, 0.25)
                else
                    myupdate_param!(model, :Consumption, :damagepersist, 0.5)
                end

                Random.seed!(26052023)

                ### Run the model so we can run scripts
                run(model)
                #scc = calculate_scc(model,2020,10.0,1.05)
                #scch4 = calculate_scch4(model,2020,0.06,1.05)
                #println(scc, scch4)

                ### Calculate the SC-CH4 and SC-CO2 in Monte Carlo-mode
                ## Miniloop over pulse year
                sccresults = DataFrame(pulse_year=Int64[], scc=Float64[], scch4=Float64[])
                allsccresults = DataFrame(pulse_year=Int64[], country=Float64[], scco2=Float64[], trialnum=Float64[])
                allscch4results = DataFrame(pulse_year=Int64[], country=Float64[], scch4=Float64[], trialnum=Float64[])
                for yy in 2020:10:2100 #Set this to 2020:10:2100 to obtain results through 2100 as reported in the SM
                    if TP == "TPs"
                        subscc = calculate_scc_full_mc(model,
                                                       1000, # MC reps
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
                                                       yy, # pulse year
                                                       10.0, # pulse size
                                                       1.05; calc_nationals=calc_nationals) # EMUC

                        subscch4 = calculate_scch4_full_mc(model,
                                                        1000, # MC reps
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
                                                        yy, # pulse year
                                                        0.06, # pulse size
                                                        1.05; calc_nationals=calc_nationals) # EMUC
                    elseif TP=="NoOMH"
                        subscc = calculate_scc_full_mc(model,
                                                        1000, # MC reps
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
                                                        yy, # pulse year
                                                        10.0, # pulse size
                                                        1.05; calc_nationals=calc_nationals) # EMUC

                        subscch4 = calculate_scch4_full_mc(model,
                                                        1000, # MC reps
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
                                                        yy, # pulse year
                                                        0.06, # pulse size
                                                        1.05; calc_nationals=calc_nationals) # EMUC

                    else
                        subscc = calculate_scc_full_mc(model,
                                                       1000, # MC reps
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
                                                       yy, # pulse year
                                                       10.0, # pulse size
                                                       1.05; calc_nationals=calc_nationals) # EMUC

                        subscch4 = calculate_scch4_full_mc(model,
                                                           1000, # MC reps
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
                                                           yy, # pulse year
                                                           0.06, # pulse size
                                                           1.05; calc_nationals=calc_nationals) # EMUC
                    end

                    #Ensure results write correctly even if an MC draw crashes
                    if calc_nationals
                        allscc = simdataframe(model, subscc, :other, :nationalscc)
                        scc = allscc.scco2[allscc.country .== "global"]
                        allscc.pulse_year .= yy
                        allsccresults = vcat(allsccresults, allscc)

                        allscch4 = simdataframe(model, subscch4, :other, :nationalscch4)
                        scch4 = allscch4.scch4[allscch4.country .== "global"]
                        allscch4.pulse_year .= yy
                        allscch4results = vcat(allscch4results, allscch4)
                    else
                        scc=subscc[:other]
                        scch4=subscch4[:other]
                    end

                    if length(scc) < length(scch4)
                        scc = [scc; fill(missing, length(scch4) - length(scc))]
                    elseif length(scch4) < length(scc)
                        scch4 = [scch4; fill(missing, length(scc) - length(scch4))]
                    end

                    sccresults = vcat(sccresults, DataFrame(pulse_year=yy, scc=scc, scch4=scch4))
                end

                CSV.write("../results/sccs-$x$z-$y-$TP-$persistence-Replication-AllYears-26052023.csv", sccresults)#=REMOVE SUFFIX AFTERWARDS=#
                #if calc_nationals
                #    CSV.write("../results/natscch4s-$x$z-$y-$TP-$persistence-Replication-26052023.csv", allscch4results)#=REMOVE  SUFFIX AFTERWARDS=#
                #end
            end
    end
end
end
