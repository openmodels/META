using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")
include("../src/bge.jl")

calc_nationals = false

model = full_model(;
                   rcp = "CP-Base", # Concatenate correct scenario-variant name
                   ssp = "GMP",
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

myupdate_param!(model, :Consumption, :damagepersist, 0.5)

Random.seed!(26052023)

### Run the model so we can run scripts
run(model)

function get_nonscc_results(inst, draws, ii; save_rvs)
    mcres = getsim_full(inst, draws, ii; save_rvs=save_rvs)
    bgeres = calculate_bge(inst)
    mcres[:bge] = bgeres

    mcres
end

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
                   getsim=get_nonscc_results)

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

# Save non-other values
params = Dict{Symbol, Vector{Union{Missing, Float64}}}()
for ii in 1:length(results[:other])
    for (key, value) in results[:other][ii]
        if value isa Union{Missing, Float64}
            if key in keys(params)
                push!(params[key], value)
            else
                params[key] = [value]
            end
        end
    end
end
CSV.write("../results/params-$x$z-$y-$TP-$persistence.csv", DataFrame(params))

### Calculate the SC-CO2 in MC mode
## Miniloop over pulse year
sccresults = DataFrame(pulse_year=Int64[], scc=Float64[], scch4=Float64[])
allsccresults = DataFrame(pulse_year=Int64[], country=Float64[], scco2=Float64[], trialnum=Float64[])
allscch4results = DataFrame(pulse_year=Int64[], country=Float64[], scch4=Float64[], trialnum=Float64[])

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
                               2020, # pulse year
                               10.0, # pulse size
                               1.02; save_rvs=true, calc_nationals=calc_nationals) # EMUC

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
                                   2020, # pulse year
                                   0.06, # pulse size
                                   1.02; save_rvs=true, calc_nationals=calc_nationals) # EMUC

scc = [entry[:globalscc] for entry in subscc[:other]]
scch4 = [entry[:globalscch4] for entry in subscch4[:other]]

if length(scc) < length(scch4)
    scc = [scc; fill(missing, length(scch4) - length(scc))]
elseif length(scch4) < length(scc)
    scch4 = [scch4; fill(missing, length(scc) - length(scch4))]
end

sccresults = vcat(sccresults, DataFrame(pulse_year=2020, scc=scc, scch4=scch4))

params = Dict{Symbol, Vector{Union{Missing, Float64}}}()
for ii in 1:length(subscc[:other])
    for (key, value) in subscc[:other][ii]
        if value isa Union{Missing, Float64}
            if key in keys(params)
                push!(params[key], value)
            else
                params[key] = [value]
            end
        end
    end
end
CSV.write("../results/params-scc-$x$z-$y-$TP-$persistence.csv", DataFrame(params))

params = Dict{Symbol, Vector{Union{Missing, Float64}}}()
for ii in 1:length(subscch4[:other])
    for (key, value) in subscch4[:other][ii]
        if value isa Union{Missing, Float64}
            if key in keys(params)
                push!(params[key], value)
            else
                params[key] = [value]
            end
        end
    end
end
CSV.write("../results/params-scch4-$x$z-$y-$TP-$persistence.csv", DataFrame(params))

df1 = simdataframe(model, subscc, :SLRModel, :SLR)
df2 = simdataframe(model, subscc, :TemperatureConverter, :T_AT)
df3 = simdataframe(model, subscch4, :SLRModel, :SLR)
df4 = simdataframe(model, subscch4, :TemperatureConverter, :T_AT)

df = df1[!, [:time, :trialnum]]
df[!, :SLR_SCC] = df1.SLR
df[!, :T_AT_SCC] = df2.T_AT
df[!, :SLR_SCCH4] = df3.SLR
df[!, :T_AT_SCCH4] = df4.T_AT
CSV.write("../results/bytime-scc-$x$z-$y-$TP-$persistence.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

CSV.write("../results/sccs-$x$z-$y-$TP-$persistence.csv", sccresults)
