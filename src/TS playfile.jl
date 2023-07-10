using Mimi
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")

df = DataFrame(country=String[], scch4=Float64[])
subres = ["string", 1.1]#float #CH4 in Mt rather than Gt
push!(df, subres)

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

for (cc, strcc) in zip((1:dim_count(model, :country)), (dim_keys(model, :country)))
    print(cc)
    println(strcc)
    println()
end
#=
for cc in dim_keys(model, :country)
    print(cc)
    println()
end

for strcc in 1:dim_count(model, :country)
    print(strcc)
    println()
end

#SOMEHOW JULIA GRABS THE FIRST TWO ELEMNTS OF EACH AND MERGES THEM. WHY?
=#
