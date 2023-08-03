using Mimi
using CSV
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")


global model = full_model(; #Why does full_model not take the co2 ch4 and warming arguments anymore like in ResultsAERE.jl? Must be multiple dispatch, but then why does it not call the version of the function that can do that?
    rcp = "CP-Base", 
    ssp = "SSP2",
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

scch4 = calculate_scch4_national(model,
    2020, # pulse year
    0.06, # pulse size
    1.5) # EMUC

scco2 = calculate_scc_national(model,
    2020, # pulse year
    10., # pulse size
    1.5) # EMUC

national_results = innerjoin(scch4, scco2, on = :country) # 'innerjoin' is similar to Stata's 'merge'

CSV.write("national_marginal damages.csv", national_results)