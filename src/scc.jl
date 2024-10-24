using Mimi
include("../src/MimiMETA.jl")
include("../src/montecarlo.jl")

## Non-Monte Carlo SCC calculation

function calculate_scc(model::Model, pulse_year::Int64, pulse_size::Float64, emuc::Float64)
    mm = calculate_scc_setup(model, pulse_year, pulse_size)
    run(mm)
    calculate_scc_marginal(mm, pulse_year, emuc)
end

function calculate_scc_national(model::Model, pulse_year::Int64, pulse_size::Float64, emuc::Float64)
    mm = calculate_scc_setup(model, pulse_year, pulse_size)
    run(mm)
    calculate_scc_marginal_national(mm, pulse_year, emuc)
end

## Helper functions

function calculate_scc_setup(model::Model, pulse_year::Int64, pulse_size::Float64)
    mm = create_marginal_model(model, pulse_size)

    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
    run(mm)

    mm.modified[:CO2Converter, :co2_extra][pulse_index] = pulse_size

    mm
end

function calculate_scc_marginal(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64)
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    globalwelfare_marginal = sum(mm[:Utility, :world_disc_utility][pulse_index:end])

    global_conspc = sum(mm.base[:Consumption, :conspc][pulse_index, :] .* mm.base[:Utility, :pop][pulse_index, :]) / mm.base[:Utility, :world_population][pulse_index]
    -(globalwelfare_marginal / (global_conspc^-emuc)) / 1e9
end

function calculate_scc_marginal_national(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64)
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    #Calculate marginal welfare for each country
    nationalwelfare_marginals = sum(mm[:Utility, :disc_utility][pulse_index:end, :], dims=1)

    #Loop over countries
    results = DataFrame(country=String[], scco2=Float64[])
    for (cc, strcc) in zip((1:dim_count(model, :country)), (dim_keys(model, :country)))
        #Calculate consumption per capita for each country
        national_conspc = mm.base[:Consumption, :conspc][pulse_index, cc]

        subres = [strcc, -(nationalwelfare_marginals[cc] / (national_conspc^-emuc)) / 1e9]

        #Calculate SC-CO2 for each country
        push!(results, subres)
    end

    results
end

function calculate_scc_marginal_national_globalnormalization(mm::Union{MarginalModel, MarginalInstance}, pulse_year::Int64, emuc::Float64) # Normalizes by global rather than national consumption
    pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)

    #Calculate marginal welfare for each country
    nationalwelfare_marginals = sum(mm[:Utility, :disc_utility][pulse_index:end, :], dims=1)

    #Grab global consumption per capita
    global_conspc = sum(mm.base[:Consumption, :conspc][pulse_index, :] .* mm.base[:Utility, :pop][pulse_index, :]) / mm.base[:Utility, :world_population][pulse_index]

    #Loop over countries
    results = DataFrame(country=String[], scco2=Float64[])
    for (cc, strcc) in zip((1:dim_count(model, :country)), (dim_keys(model, :country)))
        subres = [strcc, -(nationalwelfare_marginals[cc] / (global_conspc^-emuc)) / 1e9]

        #Calculate SC-CO2 for each country
        push!(results, subres)
    end

    results
end

## Monte Carlo SCC calculations

function calculate_scc_base_mc(model::Model, trials::Int64, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true)
    mm = calculate_scc_setup(model, pulse_year, pulse_size)

    function setsim_base_scc(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64)
        setsim_base(inst, draws, ii)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CO2Converter, :co2_extra][pulse_index] = pulse_size
    end

    function getsim_base_scc(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame; save_rvs::Bool=true)
        globalscc = calculate_scc_marginal(inst, pulse_year, emuc)
        if calc_nationals
            nationalscc = calculate_scc_marginal_national(inst, pulse_year, emuc)
            push!(nationalscc, ["global", globalscc])
            nationalscc
        else
            globalscc
        end
    end

    sim_base(mm, trials, persist_dist, emuc_dist, prtp_dist; save_rvs=false,
             setsim=setsim_base_scc,
             getsim=getsim_base_scc)
end

if false
    model = base_model(; rcp="RCP4.5", tdamage="pointestimate", slrdamage="mode")
    calculate_scc(model, 2020, 10., 1.5)
    calculate_scc_national(model, 2020, 10., 1.5)
    sccs = calculate_scc_base_mc(model, 100, false, false, false, 2020, 10., 1.5)
    df = simdataframe(model, sccs, :other, :*)
    ## [mean(sccs[:other]), std(sccs[:other]), median(sccs[:other])] # This line only works if calc_nationals = false
end

function calculate_scc_full_mc(model::Model, trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, ism_used::Bool, omh_used::Bool, amoc_used::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true)
    mm = calculate_scc_setup(model, pulse_year, pulse_size)

    function setsim_full_scc(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64, ism_used::Bool, omh_used::Bool, amoc_used::Bool, amazon_calib::String, wais_calib::String, ais_dist::Bool, saf_calib::String)
        setsim_full(inst, draws, ii, ism_used, omh_used, amoc_used, amazon_calib, wais_calib, ais_dist, saf_calib)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CO2Converter, :co2_extra][pulse_index] = pulse_size
    end

    function getsim_full_scc(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame; save_rvs::Bool=true)
        globalscc = calculate_scc_marginal(inst, pulse_year, emuc)
        if calc_nationals
            nationalscc = calculate_scc_marginal_national(inst, pulse_year, emuc)
            push!(nationalscc, ["global", globalscc])
            nationalscc
        else
            globalscc
        end
    end

    sim_full(mm, trials, pcf_calib, amazon_calib, gis_calib, wais_calib, saf_calib,
             ais_dist, ism_used, omh_used, amoc_used, persist_dist, emuc_dist, prtp_dist; save_rvs=false,
             setsim=setsim_full_scc,
             getsim=getsim_full_scc)
end

function calculate_scc_full_mc_globalnormalization(model::Model, trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, ism_used::Bool, omh_used::Bool, amoc_used::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool, pulse_year::Int64, pulse_size::Float64, emuc::Float64; calc_nationals::Bool=true)
    mm = calculate_scc_setup(model, pulse_year, pulse_size)

    function setsim_full_scc(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64, ism_used::Bool, omh_used::Bool, amoc_used::Bool, amazon_calib::String, wais_calib::String, ais_dist::Bool, saf_calib::String)
        setsim_full(inst, draws, ii, ism_used, omh_used, amoc_used, amazon_calib, wais_calib, ais_dist, saf_calib)
        pulse_index = findfirst(dim_keys(model, :time) .== pulse_year)
        inst.modified[:CO2Converter, :co2_extra][pulse_index] = pulse_size
    end

    function getsim_full_scc_globalnormalization(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame; save_rvs::Bool=true)
        globalscc = calculate_scc_marginal(inst, pulse_year, emuc)
        if calc_nationals
            nationalscc = calculate_scc_marginal_national_globalnormalization(inst, pulse_year, emuc)
            push!(nationalscc, ["global", globalscc])
            nationalscc
        else
            globalscc
        end
    end

    sim_full(mm, trials, pcf_calib, amazon_calib, gis_calib, wais_calib, saf_calib,
             ais_dist, ism_used, omh_used, amoc_used, persist_dist, emuc_dist, prtp_dist; save_rvs=false,
             setsim=setsim_full_scc,
             getsim=getsim_full_scc_globalnormalization)
end

if false
    model = full_model(rcp="RCP4.5", ssp="SSP2", ais="WAIS")
    calculate_scc(model, 2020, 1.0, 1.5)
    sccs = calculate_scc_full_mc(model, 100,
                                 "Fit of Hope and Schaefer (2016)", # PCF
                                 "Cai et al. central value", # AMAZ
                                 "Nordhaus central value", # GIS
                                 "Distribution", # WAIS
                                 "Distribution", # SAF
                                 false, # ais_used
                                 true, # ism_used
                                 true, # omh_used
                                 true, # amoc_used
                                 false, # persit
                                 false, # emuc
                                 false, # prtp
                                 2020, 10., 1.5)
    df = simdataframe(model, sccs, :other, :*)
    ## [mean(sccs[:other]), std(sccs[:other]), median(sccs[:other])] # This line only works if calc_nationals = false

    model = full_model(rcp="RCP4.5", ssp="SSP2")
    calculate_scc(model, 2020, 1.0, 1.5)
    sccs = calculate_scc_full_mc(model, 100,
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
                                 2020, 10., 1.5)
    df = simdataframe(model, sccs, :other, :*)
    ## [mean(sccs[:other]), std(sccs[:other]), median(sccs[:other])] # This line only works if calc_nationals = false
end
