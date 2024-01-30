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
                                          nonmarketdamage = true)

myupdate_param!(model, :Consumption, :damagepersist, 0.25)

Random.seed!(26052023)

### Run the model so we can run scripts
run(model)

                function get_nonscc_results(inst, draws; save_rvs)
                    mcres = getsim_full(inst, draws; save_rvs=save_rvs)
                    bgeres = calculate_bge(inst)
                    mcres[:bge] = bgeres
                    mcres[:GISModel_VGIS] = inst[:GISModel, :VGIS]
                    #mcres[:WAISmodel_I_WAIS] = inst[:WAISmodel, :I_WAIS]
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
                                       save_rvs=true,
                                       getsim=get_nonscc_results, throwex=true)

                run(model) # model is overwritten in some cases

                #This runs as before
                df = simdataframe(model, results, :SLRModel, :SLR)

                #Here the script breaks
                #=What I've tried
                -explore(model) to check that :GISmodel is loaded
                -Try different names for GISmodel (gismodel, GIS, gis)
                -Try to load a different TP component, and grab VGIS from :Interactions
                =#
                df = simdataframe(model, results, :GISModel, :VGIS)
                for (comp, var) in [(:OMH, :I_OMH), (:ISMModel, :mNINO3pt4), (:AmazonDieback, :I_AMAZ), (:AMOC, :I_AMOC), (:AISmodel, :totalSLR_Ross), (:AISmodel, :totalSLR_Amundsen), (:AISmodel, :totalSLR_Weddell), (:AISmodel, :totalSLR_Peninsula), (:AISmodel, :totalSLR_EAIS), (:PCFModel, :PF_extent)]
                    subdf = simdataframe(model, results, comp, var)
                    df[!, names(subdf)[2]] = subdf[!, 2]
                end
                CSV.write("../results/TPs_bytime-$x$z-$y-$TP-$persistence.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

