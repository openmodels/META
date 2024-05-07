using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")
include("../src/bge.jl")

nummc = 10

function extract_params(results)
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
    results
end

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

function getsim_extra(inst, results)
    # y_it = A_it (1 - S_t c_i) -> sum_i p_it log(y_it) = sum_i p_it log(A_it) - S_t sum_i p_it c_i
    results[:slrcoeffstat] = sum(inst[:Utility, :pop][1, :] .* inst[:Consumption, :slrcoeff])
    # Don't bother with beta1, beta2 since not country-specific
    # y_it = A_it (1 + g_it + b1 (T_it - T_i0) + b2 (T_it^2 - T_i0^2)) -> sum_i p_it (g_it + b1 (T_it - T_i0) + b2 (T_it^2 - T_i0^2)) -> sum_i p_it (b1 dT + b2 ((dT + T_i0)^2 - T_i0^2)) = sum_i p_it (b1 dT + b2 (dT^2 + 2 dT T_i0)) = dT sum_i p_it (b1 + b2 (dT + 2 T_i0))
    results[:AISmodel_β_EAIS] = inst[:AISmodel_β_EAIS]
    results[:AISmodel_β_EAIS] = inst[:AISmodel_β_EAIS]
    results[:AISmodel_δ_EAIS] = inst[:AISmodel_δ_EAIS]
    results[:AISmodel_β_Ross] = inst[:AISmodel_β_Ross]
    results[:AISmodel_δ_Ross] = inst[:AISmodel_δ_Ross]
    results[:AISmodel_β_Amundsen] = inst[:AISmodel_β_Amundsen]
    results[:AISmodel_δ_Amundsen] = inst[:AISmodel_δ_Amundsen]
    results[:AISmodel_β_Weddell] = inst[:AISmodel_β_Weddell]
    results[:AISmodel_δ_Weddell] = inst[:AISmodel_δ_Weddell]
    results[:AISmodel_β_Peninsula] = inst[:AISmodel_β_Peninsula]
    results[:AISmodel_δ_Peninsula] = inst[:AISmodel_δ_Peninsula]
    results[:AISmodel_R_functions_EAIS] = sum(inst[:AISmodel_R_functions_EAIS] .* (1:length(inst[:AISmodel_R_functions_EAIS])))
    results[:AISmodel_R_functions_Ross] = sum(inst[:AISmodel_R_functions_Ross] .* (1:length(inst[:AISmodel_R_functions_Ross])))
    results[:AISmodel_R_functions_Amundsen] = sum(inst[:AISmodel_R_functions_Amundsen] .* (1:length(inst[:AISmodel_R_functions_Amundsen])))
    results[:AISmodel_R_functions_Weddell] = sum(inst[:AISmodel_R_functions_Weddell] .* (1:length(inst[:AISmodel_R_functions_Weddell])))
    results[:AISmodel_R_functions_Peninsula] = sum(inst[:AISmodel_R_functions_Peninsula] .* (1:length(inst[:AISmodel_R_functions_Peninsula])))
    # ISM
    results[:Pbar] = mean(inst[:ISMModel, :Pbar])
    # Triggering logic
    # Suppose that there's a threshold T, so log(T) ~ N
    # Now I observe a bunch of values. When do I get my first value below the threshold? Average over them.
    omhyears = []
    amocyears = []
    amazyears = []
    waisyears = []
    for threshold in [1e-3, 1e-2, 1e-1]
        omhyear = findfirst(inst[:OMH_uniforms] .< threshold)
        if omhyear == nothing
            omhyear = length(inst[:OMH_uniforms]) + 1
        end
        amocyear = findfirst(inst[:AMOC_uniforms] .< threshold)
        if amocyear == nothing
            amocyear = length(inst[:AMOC_uniforms]) + 1
        end
        amazyear = findfirst(inst[:AmazonDieback_uniforms] .< threshold)
        if amazyear == nothing
            amazyear = length(inst[:AmazonDieback_uniforms]) + 1
        end
        waisyear = findfirst(inst[:WAISmodel_uniforms] .< threshold)
        if waisyear == nothing
            waisyear = length(inst[:WAISmodel_uniforms]) + 1
        end

        append!(omhyears, omhyear)
        append!(amocyears, amocyear)
        append!(amazyears, amazyear)
        append!(waisyears, waisyear)
    end

    results[:OMH_year] = mean(omhyears)
    results[:AMOC_year] = mean(amocyears)
    results[:AMAZ_year] = mean(amazyears)
    results[:waisyears] = mean(waisyears)
end

### Calculate the SC-CO2 in MC mode
subscc = calculate_scc_full_mc(model,
                               nummc, # MC reps
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
                               1.02; save_rvs=true, calc_nationals=false) # EMUC

subscch4 = calculate_scch4_full_mc(model,
                                   nummc, # MC reps
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
                                   1.02; save_rvs=true, calc_nationals=false) # EMUC

scc = [entry[:globalscc] for entry in subscc[:other]]
scch4 = [entry[:globalscch4] for entry in subscch4[:other]]

if length(scc) < length(scch4)
    scc = [scc; fill(missing, length(scch4) - length(scc))]
elseif length(scch4) < length(scc)
    scch4 = [scch4; fill(missing, length(scc) - length(scch4))]
end

CSV.write("../results/sccs-CP-Base-SSP2-GSA-0.5.csv", DataFrame(pulse_year=2020, scc=scc, scch4=scch4))

CSV.write("../results/params-scc-CP-Base-SSP2-GSA-0.5.csv", DataFrame(extract_params(subscc)))
CSV.write("../results/params-scch4-CP-Base-SSP2-GSA-0.5.csv", DataFrame(extract_params(subscch4))

df1 = simdataframe(model, subscc, :SLRModel, :SLR)
df2 = simdataframe(model, subscc, :TemperatureConverter, :T_AT)
df3 = simdataframe(model, subscch4, :SLRModel, :SLR)
df4 = simdataframe(model, subscch4, :TemperatureConverter, :T_AT)

df = df1[!, [:time, :trialnum]]
df[!, :SLR_SCC] = df1.SLR
df[!, :T_AT_SCC] = df2.T_AT
df[!, :SLR_SCCH4] = df3.SLR
df[!, :T_AT_SCCH4] = df4.T_AT
CSV.write("../results/bytime-scc-CP-Base-SSP2-GSA-0.5.csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

