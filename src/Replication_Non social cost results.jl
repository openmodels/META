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
include("../src/bge.jl")

calc_nationals = true

# Scenarios
for (x,y) in [("CP-", "SSP2"), ("NP-", "SSP3"), ("1.5-", "SSP1")]
    for z in ["Base", "GMP", "GMP-LowCH4", "GMP-HighCH4"]

        # TP configurations
        for TP in ["NoTPs",#="TPs",=#"NoOMH"]
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

                function get_nonscc_results_TPs(inst, draws, ii; save_rvs)
                    mcres = getsim_full(inst, draws, ii; save_rvs=save_rvs)
                    #bgeres = calculate_bge(inst)
                    #mcres[:bge] = bgeres
                    mcres[:GISModel_VGIS] = inst[:GISModel, :VGIS]
                    mcres[:OMH_I_OMH] = inst[:OMH, :I_OMH]
                    mcres[:ISMModel_mNINO3pt4] = inst[:ISMModel, :mNINO3pt4]
                    mcres[:AmazonDieback_I_AMAZ] = inst[:AmazonDieback, :I_AMAZ]
                    mcres[:AMOC_I_AMOC] = inst[:AMOC, :I_AMOC]
                    mcres[:AISmodel_totalSLR_Ross] = inst[:AISmodel, :totalSLR_Ross]
                    mcres[:AISmodel_totalSLR_Amundsen] = inst[:AISmodel, :totalSLR_Amundsen]
                    mcres[:AISmodel_totalSLR_Weddell] = inst[:AISmodel, :totalSLR_Weddell]
                    mcres[:AISmodel_totalSLR_Peninsula] = inst[:AISmodel, :totalSLR_Peninsula]
                    mcres[:AISmodel_totalSLR_EAIS] = inst[:AISmodel, :totalSLR_EAIS]
                    mcres[:PCFModel_PF_extent] = inst[:PCFModel, :PF_extent]

                    mcres
                end
                
                function get_nonscc_results_NoOMH(inst, draws, ii; save_rvs)
                    mcres = getsim_full(inst, draws, ii; save_rvs=save_rvs)
                    #bgeres = calculate_bge(inst)
                    #mcres[:bge] = bgeres
                    mcres[:GISModel_VGIS] = inst[:GISModel, :VGIS]
                    #mcres[:OMH_I_OMH] = inst[:OMH, :I_OMH]
                    mcres[:ISMModel_mNINO3pt4] = inst[:ISMModel, :mNINO3pt4]
                    mcres[:AmazonDieback_I_AMAZ] = inst[:AmazonDieback, :I_AMAZ]
                    mcres[:AMOC_I_AMOC] = inst[:AMOC, :I_AMOC]
                    mcres[:AISmodel_totalSLR_Ross] = inst[:AISmodel, :totalSLR_Ross]
                    mcres[:AISmodel_totalSLR_Amundsen] = inst[:AISmodel, :totalSLR_Amundsen]
                    mcres[:AISmodel_totalSLR_Weddell] = inst[:AISmodel, :totalSLR_Weddell]
                    mcres[:AISmodel_totalSLR_Peninsula] = inst[:AISmodel, :totalSLR_Peninsula]
                    mcres[:AISmodel_totalSLR_EAIS] = inst[:AISmodel, :totalSLR_EAIS]
                    mcres[:PCFModel_PF_extent] = inst[:PCFModel, :PF_extent]

                    mcres
                end
                
                function get_nonscc_results_NoTPs(inst, draws, ii; save_rvs)
                    mcres = getsim_full(inst, draws, ii; save_rvs=save_rvs)
                    #bgeres = calculate_bge(inst)
                    #mcres[:bge] = bgeres
                    mcres
                end
                
                ### Run the model in MC mode
                if TP == "TPs"
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
                                       save_rvs=true,
                                       getsim=get_nonscc_results_TPs)
                elseif TP == "NoOMH"
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
                                        save_rvs=true,
                                        getsim=get_nonscc_results_NoOMH)
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
                                       save_rvs=true,
                                       getsim=get_nonscc_results_NoTPs)
                end
                run(model) # model is overwritten in some cases

                #=
                bgeresults = DataFrame(mc=Int64[], country=String[], bge=Float64[])
                for mc in 1:length(results[:other])
                    bgeres = results[:other][mc][:bge]
                    bgeres[!, :mc] .= mc
                    bgeresults = vcat(bgeresults, bgeres)
                end

                CSV.write("../results/bge-$x$z-$y-$TP-$persistence.csv", bgeresults)
                =#

                #Export global results
                df = simdataframe(model, results, :SLRModel, :SLR)
                for (comp, var) in [(:TotalDamages, :total_damages_global_peryear_percent), (:TemperatureConverter, :T_AT)]
                    subdf = simdataframe(model, results, comp, var)
                    df[!, names(subdf)[2]] = subdf[!, 2]
                end
                CSV.write("../results/bytime-$x$z-$y-$TP-$persistence-26052023.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])


                #Export TP indicators if NoOMH run
                if TP == "NoOMH"
                    df = simdataframe(model, results, :GISModel, :VGIS)
                    for (comp, var) in [#=(:OMH, :I_OMH), =#(:ISMModel, :mNINO3pt4), (:AmazonDieback, :I_AMAZ), (:AMOC, :I_AMOC), (:AISmodel, :totalSLR_Ross), (:AISmodel, :totalSLR_Amundsen), (:AISmodel, :totalSLR_Weddell), (:AISmodel, :totalSLR_Peninsula), (:AISmodel, :totalSLR_EAIS), (:PCFModel, :PF_extent)]
                        subdf = simdataframe(model, results, comp, var)
                        df[!, names(subdf)[2]] = subdf[!, 2]
                    end

                    CSV.write("../results/TPs_bytime-$x$z-$y-$TP-$persistence-26052023.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])
                else
                    println("$TP: No TP results to export")
                end

                #Export country-level damages
                df = simdataframe(model, results, :TotalDamages, :total_damages_percap_peryear_percent)
                CSV.write("../results/bytimexcountry-$x$z-$y-$TP-$persistence-26052023.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

                #Export country-level temperatures
                df = simdataframe(model, results, :PatternScaling, :T_country)
                CSV.write("../results/bytimexcountry2-$x$z-$y-$TP-$persistence-26052023.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])
            end
        end
    end
end
