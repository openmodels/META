using Mimi
import Random
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")
include("../src/scch4.jl")
include("../src/scc.jl")
include("../src/bge.jl")

nummc = 1000

function extract_params(results)
    params = Dict{Symbol, Vector{Union{Missing, Number}}}()
    for ii in 1:length(results[:other])
        if isnothing(results[:other][ii])
            for key in keys(params)
                push!(params[key], missing)
            end
        else
            for (key, value) in results[:other][ii]
                if value isa Union{Missing, Number}
                    if key in keys(params)
                        push!(params[key], value)
                    else
                        params[key] = [value]
                    end
                end
            end
        end
    end
    params
end

function getsim_extra(inst, results)
    model = inst.base

    results[:temperature_T] = model[:temperature, :T]

    # y_it = A_it (1 - S_t c_i) -> sum_i p_it log(y_it) = sum_i p_it log(A_it) - S_t sum_i p_it c_i
    results[:slrcoeffstat] = sum(model[:Utility, :pop][dim_keys(model, :time) .== 2010, :] .* model[:Consumption, :slrcoeff])
    # Don't bother with beta1, beta2 since not country-specific
    # y_it = A_it (1 + g_it + b1 (T_it - T_i0) + b2 (T_it^2 - T_i0^2)) -> sum_i p_it (g_it + b1 (T_it - T_i0) + b2 (T_it^2 - T_i0^2)) -> sum_i p_it (b1 dT + b2 ((dT + T_i0)^2 - T_i0^2)) = sum_i p_it (b1 dT + b2 (dT^2 + 2 dT T_i0)) = dT sum_i p_it (b1 + b2 (dT + 2 T_i0))

    if has_comp(model, :AISmodel)
        results[:AISmodel_β_EAIS] = model[:AISmodel, :β_EAIS]
        results[:AISmodel_δ_EAIS] = model[:AISmodel, :δ_EAIS]
        results[:AISmodel_β_Ross] = model[:AISmodel, :β_Ross]
        results[:AISmodel_δ_Ross] = model[:AISmodel, :δ_Ross]
        results[:AISmodel_β_Amundsen] = model[:AISmodel, :β_Amundsen]
        results[:AISmodel_δ_Amundsen] = model[:AISmodel, :δ_Amundsen]
        results[:AISmodel_β_Weddell] = model[:AISmodel, :β_Weddell]
        results[:AISmodel_δ_Weddell] = model[:AISmodel, :δ_Weddell]
        results[:AISmodel_β_Peninsula] = model[:AISmodel, :β_Peninsula]
        results[:AISmodel_δ_Peninsula] = model[:AISmodel, :δ_Peninsula]
        results[:AISmodel_R_functions_EAIS] = sum(model[:AISmodel, :R_functions_EAIS] .* (1:length(model[:AISmodel, :R_functions_EAIS])))
        results[:AISmodel_R_functions_Ross] = sum(model[:AISmodel, :R_functions_Ross] .* (1:length(model[:AISmodel, :R_functions_Ross])))
        results[:AISmodel_R_functions_Amundsen] = sum(model[:AISmodel, :R_functions_Amundsen] .* (1:length(model[:AISmodel, :R_functions_Amundsen])))
        results[:AISmodel_R_functions_Weddell] = sum(model[:AISmodel, :R_functions_Weddell] .* (1:length(model[:AISmodel, :R_functions_Weddell])))
        results[:AISmodel_R_functions_Peninsula] = sum(model[:AISmodel, :R_functions_Peninsula] .* (1:length(model[:AISmodel, :R_functions_Peninsula])))
    end

    # ISM
    if has_comp(model, :ISMModel)
        results[:Pbar_exog] = mean(model[:ISMModel, :Pbar_exog][dim_keys(model, :time) .>= 2010])
    end

    # Triggering logic
    # Suppose that there's a threshold T, so log(T) ~ N
    # Now I observe a bunch of values. When do I get my first value below the threshold? Average over them.
    omhyears = []
    amocyears = []
    amazyears = []
    waisyears = []
    for scaling in [1, 0.1]
        if has_comp(model, :OMH)
            omhyear = findfirst(model[:OMH, :uniforms][dim_keys(model, :time) .>= 2010] .< scaling * model[:OMH, :p_OMH][dim_keys(model, :time) .== 2010])
            if omhyear == nothing
                omhyear = length(model[:OMH, :uniforms]) + 1
            end
            append!(omhyears, omhyear)
        end
        if has_comp(model, :AMOC)
            amocyear = findfirst(model[:AMOC, :uniforms] .< scaling * model[:AMOC, :p_AMOC][dim_keys(model, :time) .== 2010])
            if amocyear == nothing
                amocyear = length(model[:AMOC, :uniforms]) + 1
            end
            append!(amocyears, amocyear)
        end
        if has_comp(model, :AmazonDieback)
            amazyear = findfirst(model[:AmazonDieback, :uniforms] .< scaling * 5e-3) # model[:AmazonDieback, :p_AMAZ][dim_keys(model, :time) .== 2010]) <-- starts as 0
            if amazyear == nothing
                amazyear = length(model[:AmazonDieback, :uniforms]) + 1
            end
            append!(amazyears, amazyear)
        end
        if has_comp(model, :WAISmodel)
            waisyear = findfirst(model[:WAISmodel, :uniforms] .< scaling * model[:WAIS, :p_WAIS][dim_keys(model, :time) .== 2010])
            if waisyear == nothing
                waisyear = length(model[:WAISmodel, :uniforms]) + 1
            end
            append!(waisyears, waisyear)
        end
    end

    if !isempty(omhyears)
        results[:OMH_year_1] = omhyears[1]
        results[:OMH_year_p1] = omhyears[2]
    end
    if !isempty(amocyears)
        results[:AMOC_year_1] = amocyears[1]
        results[:AMOC_year_p1] = amocyears[2]
    end
    if !isempty(amazyears)
        results[:AMAZ_year_1] = amazyears[1]
        results[:AMAZ_year_p1] = amazyears[2]
    end
    if !isempty(waisyears)
        results[:waisyears_1] = waisyears[1]
        results[:waisyears_p1] = waisyears[2]
    end
end

for TP in ["TPs", "NoOMH"]
    model = full_model(;
                       rcp = "CP-Base", # Concatenate correct scenario-variant name
                       ssp = "SSP2",
                       tdamage = "pointestimate",
                       slrdamage = "mode",
                       saf = "Distribution mean",
                       interaction = true,
                       pcf = "Fit of Hope and Schaefer (2016)",
                       omh = (TP == "TPs" ? "Whiteman et al. beta 20 years" : false),
                       amaz = "Cai et al. central value",
                       gis = "Nordhaus central value",
                       ais = "AIS",
                       ism = "Value",
                       amoc = "IPSL",
                       nonmarketdamage = true)

    myupdate_param!(model, :Consumption, :damagepersist, 0.5)

    ### Run the model so we can run scripts
    run(model)

    Random.seed!(26052023)

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
                                   (TP == "TPs"), # omh_used
                                   true, # amoc_used
                                   false, # persist
                                   false, # emuc
                                   false, # prtp
                                   2020, # pulse year
                                   10.0, # pulse size
                                   1.02; save_rvs=true, calc_nationals=false, getsim_extra=getsim_extra) # EMUC

    Random.seed!(26052023)

    subscch4 = calculate_scch4_full_mc(model,
                                       nummc, # MC reps
                                       "Fit of Hope and Schaefer (2016)", # PCF
                                       "Cai et al. central value", # AMAZ
                                       "Nordhaus central value", # GIS
                                       "none", # WAIS
                                       "Distribution", # SAF
                                       true, # ais_used
                                       true, # ism_used
                                       (TP == "TPs"), # omh_used
                                       true, # amoc_used
                                       false, # persist
                                       false, # emuc
                                       false, # prtp
                                       2020, # pulse year
                                       0.06, # pulse size
                                       1.02; save_rvs=true, calc_nationals=false, getsim_extra=getsim_extra) # EMUC

    scc = [(isnothing(entry) ? missing : entry[:globalscc]) for entry in subscc[:other]]
    scch4 = [(isnothing(entry) ? missing : entry[:globalscch4]) for entry in subscch4[:other]]

    CSV.write("../results/sccs-CP-Base-SSP2-GSA-0.5-$(TP).csv", DataFrame(pulse_year=2020, scc=scc, scch4=scch4))

    CSV.write("../results/params-scc-CP-Base-SSP2-GSA-0.5-$(TP).csv", DataFrame(extract_params(subscc)))
    CSV.write("../results/params-scch4-CP-Base-SSP2-GSA-0.5-$(TP).csv", DataFrame(extract_params(subscch4)))

    df1 = simdataframe(model, subscc, :SLRModel, :SLR)
    df2 = simdataframe(model, subscc, :TemperatureConverter, :T_AT)
    df3 = simdataframe(model, subscch4, :SLRModel, :SLR)
    df4 = simdataframe(model, subscch4, :TemperatureConverter, :T_AT)

    df = df1[!, [:time, :trialnum]]
    df[!, :SLR_SCC] = df1.SLR
    df[!, :T_AT_SCC] = df2.T_AT
    df[!, :SLR_SCCH4] = df3.SLR
    df[!, :T_AT_SCCH4] = df4.T_AT
    CSV.write("../results/bytime-CP-Base-SSP2-GSA-0.5-$(TP).csv", df[(df.time .>= 2010) .& (df.time .<= 2100), :])

    df1 = simdataframe(model, subscc, :temperature, :T)
    df2 = simdataframe(model, subscch4, :temperature, :T)

    df = df1[!, [:time, :trialnum]]
    df[!, :T_SCC] = df1.T
    df[!, :T_SCCH4] = df2.T

    CSV.write("../results/bytimemore-CP-Base-SSP2-GSA-0.5-$(TP).csv", df)
end
