using Mimi
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")

## Non-Monte Carlo SCC calculation

function calculate_scch4(model::Model, pulse_year::Int64, pulse_size::Float64, emuc::Float64)
    mm = calculate_scch4_setup(model, pulse_year, pulse_size)
    run(mm)
    calculate_scch4_marginal(mm, pulse_year, emuc)
end

function calculate_scch4_national(model::Model, pulse_year::Int64, pulse_size::Float64, emuc::Float64)
    mm = calculate_scch4_setup(model, pulse_year, pulse_size)
    run(mm)
    calculate_scch4_marginal_national(mm, pulse_year, emuc)
end

## Helper functions

function calculate_scch4_setup(model::Model, pulse_year::Int64, pulse_size::Float64)
    mm = create_marginal_model(model, pulse_size)

    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
    run(mm)

    mm.modified[:CH4Converter, :ch4_extra][pulse_index] = pulse_size

    mm
end

function calculate_scch4_marginal(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64)
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    globalwelfare_marginal = sum(mm[:Utility, :world_disc_utility][pulse_index:end])

    global_conspc = sum(mm.base[:Consumption, :conspc][pulse_index, :] .* mm.base[:Utility, :pop][pulse_index, :]) / mm.base[:Utility, :world_population][pulse_index]
    -(globalwelfare_marginal / (global_conspc^-emuc)) / 1e6 #CH4 in Mt rather than Gt
end

function calculate_scch4_marginal_national(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64)
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    #Calculate marginal welfare for each country
    nationalwelfare_marginals = sum(mm[:Utility, :disc_utility][pulse_index:end, :], dims=1)

    #Loop over countries
    results = DataFrame(country=String[], scch4=Float64[])
    for (cc, strcc) in zip((1:dim_count(model, :country)), (dim_keys(model, :country)))
        #Calculate consumption per capita for each country
        national_conspc = mm.base[:Consumption, :conspc][pulse_index, cc]

        subres = [strcc, -(nationalwelfare_marginals[cc] / (national_conspc^-emuc)) / 1e6] #CH4 in Mt rather than Gt

        #Calculate SC-CH4 for each country
        push!(results, subres)
    end

    results
end

function calculate_scch4_marginal_national_globalnormalization(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64)
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    #Calculate marginal welfare for each country
    nationalwelfare_marginals = sum(mm[:Utility, :disc_utility][pulse_index:end, :], dims=1)

    #Grab global consumption per capita
    global_conspc = sum(mm.base[:Consumption, :conspc][pulse_index, :] .* mm.base[:Utility, :pop][pulse_index, :]) / mm.base[:Utility, :world_population][pulse_index]

    #Loop over countries
    results = DataFrame(country=String[], scch4=Float64[])
    for (cc, strcc) in zip((1:dim_count(model, :country)), (dim_keys(model, :country)))
        subres = [strcc, -(nationalwelfare_marginals[cc] / (global_conspc^-emuc)) / 1e6] #CH4 in Mt rather than Gt

        #Calculate SC-CH4 for each country
        push!(results, subres)
    end

    results
end

## Monte Carlo SCC calculations

function calculate_scch4_base_mc(model::Model, trials::Int64, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true)
    mm = calculate_scch4_setup(model, pulse_year, pulse_size)

    function setsim_base_scch4(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64)
        setsim_base(inst, draws, ii)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CH4Converter, :ch4_extra][pulse_index] = pulse_size
    end

    function getsim_base_scch4(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64; save_rvs::Bool=true)
        globalscch4 = calculate_scch4_marginal(inst, pulse_year, emuc)
        if calc_nationals
            nationalscch4 = calculate_scch4_marginal_national(inst, pulse_year, emuc)
            push!(nationalscch4, ["global", globalscch4])
            nationalscch4
        else
            globalscch4
        end
    end

    sim_base(mm, trials, persist_dist, emuc_dist, prtp_dist; save_rvs=false,
             setsim=setsim_base_scch4,
             getsim=getsim_base_scch4)
end

if false
    model = base_model(; rcp="RCP4.5", tdamage="pointestimate", slrdamage="mode")
    calculate_scch4(model, 2020, 0.06, 1.5)
    calculate_scch4_national(model, 2020, 0.06, 1.5)
    scch4s = calculate_scch4_base_mc(model, 10000, false, false, false, 2020, 0.06, 1.5)
    ## [mean(scch4s[:other]), std(scch4s[:other]), median(scch4s[:other])] # This line only works if calc_nationals = false
end

function calculate_scch4_full_mc(model::Model, trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, ism_used::Bool, omh_used::Bool, amoc_used::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true, save_rvs::Bool=false, getsim_extra::Function=(inst, results) -> nothing)
    mm = calculate_scch4_setup(model, pulse_year, pulse_size)

    function setsim_full_scch4(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64, ism_used::Bool, omh_used::Bool, amoc_used::Bool, amazon_calib::String, wais_calib::String, ais_dist::Bool, saf_calib::String)
        setsim_full(inst, draws, ii, ism_used, omh_used, amoc_used, amazon_calib, wais_calib, ais_dist, saf_calib)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CH4Converter, :ch4_extra][pulse_index] = pulse_size
    end

    function getsim_full_scch4(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64; save_rvs::Bool=true)
        results = getsim_full(inst, draws, ii; save_rvs=save_rvs)
        globalscch4 = calculate_scch4_marginal(inst, pulse_year, emuc)
        results[:globalscch4] = globalscch4
        if calc_nationals
            nationalscch4 = calculate_scch4_marginal_national(inst, pulse_year, emuc)
            push!(nationalscch4, ["global", globalscch4])
            results[:nationalscch4] = nationalscch4
        end
        getsim_extra(inst, results)

        results
    end


    sim_full(mm, trials, pcf_calib, amazon_calib, gis_calib, wais_calib, saf_calib,
             ais_dist, ism_used, omh_used, amoc_used, persist_dist, emuc_dist, prtp_dist; save_rvs=save_rvs,
             setsim=setsim_full_scch4,
             getsim=getsim_full_scch4)
end

function calculate_scch4_full_mc_globalnormalization(model::Model, trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, ism_used::Bool, omh_used::Bool, amoc_used::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true)
    mm = calculate_scch4_setup(model, pulse_year, pulse_size)

    function setsim_full_scch4(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64, ism_used::Bool, omh_used::Bool, amoc_used::Bool, amazon_calib::String, wais_calib::String, ais_dist::Bool, saf_calib::String)
        setsim_full(inst, draws, ii, ism_used, omh_used, amoc_used, amazon_calib, wais_calib, ais_dist, saf_calib)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CH4Converter, :ch4_extra][pulse_index] = pulse_size
    end

    function getsim_full_scch4_globalnormalization(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame; save_rvs::Bool=true)
        globalscch4 = calculate_scch4_marginal(inst, pulse_year, emuc)
        if calc_nationals
            nationalscch4 = calculate_scch4_marginal_national_globalnormalization(inst, pulse_year, emuc)
            push!(nationalscch4, ["global", globalscch4])
            nationalscch4
        else
            globalscch4
        end
    end


    sim_full(mm, trials, pcf_calib, amazon_calib, gis_calib, wais_calib, saf_calib,
             ais_dist, ism_used, omh_used, amoc_used, persist_dist, emuc_dist, prtp_dist; save_rvs=false,
             setsim=setsim_full_scch4,
             getsim=getsim_full_scch4_globalnormalization)
end

if false
    model = full_model(rcp="RCP4.5", ssp="SSP2")
    calculate_scch4(model, 2020, 0.06, 1.5)
    scch4s = calculate_scch4_full_mc(model, 100,
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
                                     2020, 0.06, 1.5)
    df = simdataframe(model, scch4s, :other, :*)
    ## [mean(scch4s[:other]), std(scch4s[:other]), median(scch4s[:other])] # This line only works if calc_nationals = false
end
