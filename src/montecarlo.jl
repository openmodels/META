using Mimi
using Distributions
using CSV
using DataFrames
using LinearAlgebra
using ProgressMeter
using MimiFAIRv2
include("../src/lib/presets.jl")
include("../src/lib/MimiFAIR_monte_carlo.jl")

import Mimi.ModelInstance, Mimi.has_comp, Mimi.set_param!

has_parameter(m::Model, name::Symbol) = has_parameter(m.md, name)
has_parameter(m::MarginalModel, name::Symbol) = has_parameter(m.base.md, name)
has_parameter(mi::ModelInstance, name::Symbol) = has_parameter(mi.md, name)
has_parameter(mi::MarginalInstance, name::Symbol) = has_parameter(mi.base.md, name)
has_comp(m::MarginalModel, name::Symbol) = has_comp(m.base.md, name)

aisgcms = CSV.read("../data/Basal_melt_models.csv", DataFrame)
aisresponse_EAIS = CSV.read("../data/Response functions - EAIS.csv", DataFrame)
aisresponse_Ross = CSV.read("../data/Response functions - Ross.csv", DataFrame)
aisresponse_Amundsen = CSV.read("../data/Response functions - Amundsen.csv", DataFrame)
aisresponse_Weddell = CSV.read("../data/Response functions - Weddell.csv", DataFrame)
aisresponse_Peninsula = CSV.read("../data/Response functions - Peninsula.csv", DataFrame)

function getmd(model::Model)
    model.md
end

function getmd(model::MarginalModel)
    model.base.md
end

function getmd(inst::ModelInstance)
    inst.md
end

function getmd(inst::MarginalInstance)
    inst.base.md
end

function set_param!(mm::MarginalModel, comp::Symbol, param::Symbol, glopar::Symbol, value::Float64)
    set_param!(mm.base, comp, param, glopar, value)
    set_param!(mm.modified, comp, param, glopar, value)
end

function make_lognormal(riskmu, risksd)
    mu = log(riskmu^2 / sqrt(risksd^2 + riskmu^2))
    sd = sqrt(log(1 + (risksd /  riskmu)^2))
    LogNormal(mu, sd)
end

# Master function for base model (uses helpers below)
function sim_base(model::Union{Model, MarginalModel}, trials::Int64, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool; save_rvs::Bool=true, setsim::Function=setsim_base, getsim::Function=getsim_base, throwex::Bool=false)
    draws = presim_base(trials, persist_dist, emuc_dist, prtp_dist)

    sim = create_fair_monte_carlo(model, trials; end_year=2200,
                                  data_dir=joinpath(dirname(pathof(MimiFAIRv2)), "..", "data",
                                                    "large_constrained_parameter_files"),
                                  delete_downloaded_data=false,
                                  other_mc_set=(inst, ii) -> setsim(inst, draws, ii),
                                  other_mc_get=(inst, ii) -> getsim(inst, draws, ii, save_rvs=save_rvs), throwex=throwex)
    sim()
end


function presim_base(trials::Int64, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool)
    draws = DataFrame(mc=1:trials)

    # Utility

    if persist_dist
        draws.Consumption_damagepersist = rand(Uniform(0, 1), trials)
    else
        rand(Uniform(0, 1), trials)
    end
    if emuc_dist
        draws.Consumption_EMUC = rand(TriangularDist(0.5, 2, 1.5), trials)
    else
        rand(TriangularDist(0.5, 2, 1.5), trials)
    end
    if prtp_dist
        draws.Consumption_PRTP = rand(TriangularDist(0.001, 0.02, 0.01), trials)
    else
        rand(TriangularDist(0.001, 0.02, 0.01), trials)
    end

    draws
end

function setsim_base(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64)
    for jj in 2:ncol(draws)
        if has_parameter(getmd(inst), Symbol(names(draws)[jj]))
            update_param!(inst, Symbol(names(draws)[jj]), draws[ii, jj])
        end
    end

    # Damages
    beta1, beta2 = getbhmbetas("distribution")
    update_param!(inst, :Consumption_beta1, beta1)
    update_param!(inst, :Consumption_beta2, beta2)

    update_param!(inst, :Consumption_slruniforms, rand(Uniform(0, 1), dim_count(inst, :country)))
end

function getsim_base(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64; save_rvs::Bool=true)
    ##Set up results capture
    mcres = Dict{Symbol, Any}()

    ##Geophysical results
    mcres[:SLRModel_SLR] = inst[:SLRModel, :SLR]
    mcres[:PatternScaling_T_country] = inst[:PatternScaling, :T_country]
    mcres[:TemperatureConverter_T_AT] = inst[:TemperatureConverter, :T_AT]
    mcres[:temperature_T] = inst[:temperature, :T]

    ##Economic results
    mcres[:TotalDamages_total_damages_global_peryear_percent] = inst[:TotalDamages, :total_damages_global_peryear_percent] #Population-weighted global change in consumption due to climate damages (in % of counterfactual consumption per capita)
    # mcres[:total_damages_equiv_conspc_equity] = inst[:TotalDamages, :total_damages_equiv_conspc_equity] #Equity-weighted global equivalent change in consumption due to climate damages (in % of counterfactual consumption per capita)
    mcres[:TotalDamages_total_damages_percap_peryear_percent] = inst[:TotalDamages, :total_damages_percap_peryear_percent] #Annual % loss in per capita consumption due to climate damages. All years, can later pick 2030 and 2050 snapshots.
    #BGE, SC-CO2 and SC-CH4 grabbed from post-compile scripts.

    ##Store number of MC iteration
    if save_rvs
        for jj in 2:ncol(draws)
            mcres[Symbol(names(draws)[jj])] = draws[ii, jj]
        end
        mcres[:Consumption_beta1] = inst[:Consumption, :beta1]
        mcres[:Consumption_beta2] = inst[:Consumption, :beta2]
    end

    mcres
end

function sim_full(model::Union{Model, MarginalModel}, trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, ism_used::Bool, omh_used::Bool, amoc_used::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool; save_rvs::Bool=true, setsim::Function=setsim_full, getsim::Function=getsim_full, throwex::Bool=false)
    draws = presim_full(trials, pcf_calib, amazon_calib, gis_calib, wais_calib, saf_calib, ais_dist, persist_dist, emuc_dist, prtp_dist)

    ## Ensure that all draws variables have global connections, if we included their components
    for jj in 2:ncol(draws)
        if !has_parameter(getmd(model), Symbol(names(draws)[jj]))
            component = split(names(draws)[jj], "_")[1]
            if has_comp(getmd(model), Symbol(component))
                set_param!(model, Symbol(component), Symbol(names(draws)[jj][length(component)+2:end]), Symbol(names(draws)[jj]), draws[1, jj])
            end
        end
    end
    run(model) # ensure we can use getdataframe later

    sim = create_fair_monte_carlo(model, trials; end_year=2200,
                                  data_dir=joinpath(dirname(pathof(MimiFAIRv2)), "..", "data",
                                                    "large_constrained_parameter_files"),
                                  delete_downloaded_data=false,
                                  other_mc_set=(inst, ii) -> setsim(inst, draws, ii, ism_used, omh_used, amoc_used, amazon_calib, wais_calib, ais_dist, saf_calib),
                                  other_mc_get=(inst, ii) -> getsim(inst, draws, ii, save_rvs=save_rvs), throwex=throwex)
    sim()
end

function presim_full(trials::Int64, pcf_calib::String, amazon_calib::String, gis_calib::String, wais_calib::String, saf_calib::String, ais_dist::Bool, persist_dist::Bool, emuc_dist::Bool, prtp_dist::Bool)
    draws = presim_base(trials, persist_dist, emuc_dist, prtp_dist)

    # Interactions

    dists = allinteractrates((symbol, ratemu, ratese) -> Normal(ratemu, ratese))

    draws.Interactions_gis2amoc = rand(dists["gis"]["amoc"], trials)
    draws.Interactions_wais2amoc = rand(dists["wais"]["amoc"], trials)
    draws.Interactions_amaz2amoc = rand(dists["amaz"]["amoc"], trials)
    draws.Interactions_nino2amoc = rand(dists["nino"]["amoc"], trials)
    draws.Interactions_amoc2gis = rand(dists["amoc"]["gis"], trials)
    draws.Interactions_wais2gis = rand(dists["wais"]["gis"], trials)
    draws.Interactions_amaz2gis = rand(dists["amaz"]["gis"], trials)
    draws.Interactions_nino2gis = rand(dists["nino"]["gis"], trials)
    draws.Interactions_amoc2wais = rand(dists["amoc"]["wais"], trials)
    draws.Interactions_gis2wais = rand(dists["gis"]["wais"], trials)
    draws.Interactions_amaz2wais = rand(dists["amaz"]["wais"], trials)
    draws.Interactions_nino2wais = rand(dists["nino"]["wais"], trials)
    draws.Interactions_amoc2amaz = rand(dists["amoc"]["amaz"], trials)
    draws.Interactions_gis2amaz = rand(dists["gis"]["amaz"], trials)
    draws.Interactions_wais2amaz = rand(dists["wais"]["amaz"], trials)
    draws.Interactions_nino2amaz = rand(dists["nino"]["amaz"], trials)
    draws.Interactions_amoc2nino = rand(dists["amoc"]["nino"], trials)
    draws.Interactions_gis2nino = rand(dists["gis"]["nino"], trials)
    draws.Interactions_wais2nino = rand(dists["wais"]["nino"], trials)
    draws.Interactions_amaz2nino = rand(dists["amaz"]["nino"], trials)

    # AIS

    if ais_dist
        draws.AISmodel_ω = rand(Normal(-0.05, 0.004), trials)
        draws.AISmodel_λ = rand(Uniform(7, 16), trials)
    else
        rand(Normal(-0.05, 0.004), trials)
        rand(Uniform(7, 16), trials)
    end

    # Permafrost

    if pcf_calib == "Kessler probabilistic"
        draws.PCFModel_propCH4 = rand(Normal(0.023, 0.006), trials)
        draws.PCFModel_beta_PF = rand(Normal(0.172, 0.0261), trials)
        draws.PCFModel_C_PF = rand(Normal(1035, 76.53), trials)
        draws.PCFModel_propPassive = rand(Normal(0.4, 0.055), trials)
        draws.PCFModel_tau = rand(Normal(70, 30), trials)
    else
        rand(Normal(0.023, 0.006), trials)
        rand(Normal(0.172, 0.0261), trials)
        rand(Normal(1035, 76.53), trials)
        rand(Normal(0.4, 0.055), trials)
        rand(Normal(70, 30), trials)
    end

    # Amazon

    if amazon_calib == "Distribution"
        draws.AmazonDieback_Delta_AMAZ = rand(TriangularDist(10, 250, 50), trials)
    else
        rand(TriangularDist(10, 250, 50), trials)
    end

    # GIS

    if gis_calib == "Distribution"
        draws.GISModel_avoldot0 = rand(Normal(-0.0000106, 0.0000244/0.5/100), trials) # Only works with a meltmult of 1
    else
        rand(Normal(-0.0000106, 0.0000244/0.5/100), trials)
    end

    # WAIS

    if wais_calib == "Distribution"
        draws.WAISmodel_waisrate = rand(make_lognormal(3.3 / 1000, 1.65 / 1000), trials)
    else
        rand(make_lognormal(3.3 / 1000, 1.65 / 1000), trials)
    end

    # SAF

    if saf_calib == "Distribution"
        draws.SAFModel_saf_delta = rand(TriangularDist(-1, 1, 0), trials)
        draws.SAFModel_FRT = rand(TriangularDist(10, 55, 20), trials)
    else
        rand(TriangularDist(-1, 1, 0), trials)
        rand(TriangularDist(10, 55, 20), trials)
    end

    draws
end

function setsim_full(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64, ism_used::Bool, omh_used::Bool, amoc_used::Bool, amazon_calib::String, wais_calib::String, ais_dist::Bool, saf_calib::String)
    setsim_base(inst, draws, ii)

    # AIS
    if ais_dist
        gcmchoice = rand(DiscreteUniform(1, 19), 1)[1]
        update_param!(inst, :AISmodel_β_EAIS, aisgcms.EAIS_beta[gcmchoice])
        update_param!(inst, :AISmodel_δ_EAIS, aisgcms.EAIS_delta[gcmchoice])
        update_param!(inst, :AISmodel_β_Ross, aisgcms.Ross_beta[gcmchoice])
        update_param!(inst, :AISmodel_δ_Ross, aisgcms.Ross_delta[gcmchoice])
        update_param!(inst, :AISmodel_β_Amundsen, aisgcms.Amundsen_beta[gcmchoice])
        update_param!(inst, :AISmodel_δ_Amundsen, aisgcms.Amundsen_delta[gcmchoice])
        update_param!(inst, :AISmodel_β_Weddell, aisgcms.Weddell_beta[gcmchoice])
        update_param!(inst, :AISmodel_δ_Weddell, aisgcms.Weddell_delta[gcmchoice])
        update_param!(inst, :AISmodel_β_Peninsula, aisgcms.Peninsula_beta[gcmchoice])
        update_param!(inst, :AISmodel_δ_Peninsula, aisgcms.Peninsula_delta[gcmchoice])
        icechoice = rand(DiscreteUniform(1, 17), 1)[1]
        update_param!(inst, :AISmodel_R_functions_EAIS, aisresponse_EAIS[!, icechoice + 1])
        update_param!(inst, :AISmodel_R_functions_Ross, aisresponse_Ross[!, icechoice + 1])
        update_param!(inst, :AISmodel_R_functions_Amundsen, aisresponse_Amundsen[!, icechoice + 1])
        update_param!(inst, :AISmodel_R_functions_Weddell, aisresponse_Weddell[!, icechoice + 1])
        update_param!(inst, :AISmodel_R_functions_Peninsula, aisresponse_Peninsula[!, icechoice + 1])
    else
        rand(DiscreteUniform(1, 19), 1)
        rand(DiscreteUniform(1, 17), 1)
    end

    # SAF

    if saf_calib != "none"
        # Assume default F2x to get ECS
        FAIR_ECS = (sum(inst[:temperature, :q]))*3.759
        update_param!(inst, :SAFModel_ECS, FAIR_ECS) # SAFModel.ECS
    end

    # ISM

    if ism_used
        update_param!(inst, :ISMModel_uniforms, rand(Uniform(0, 1), (dim_count(inst, :time), dim_count(inst, :monsoonsteps))))
    else
        rand(Uniform(0, 1), (dim_count(inst, :time), dim_count(inst, :monsoonsteps)))
    end

    # OMH

    if omh_used
        update_param!(inst, :OMH_uniforms, rand(Uniform(0, 1), dim_count(inst, :time)))
    else
        rand(Uniform(0, 1), dim_count(inst, :time))
    end

    # AMOC

    if amoc_used
        update_param!(inst, :AMOC_uniforms, rand(Uniform(0, 1), dim_count(inst, :time)))
    else
        rand(Uniform(0, 1), dim_count(inst, :time))
    end

    # Amazon

    if amazon_calib != "none"
        update_param!(inst, :AmazonDieback_uniforms, rand(Uniform(0, 1), dim_count(inst, :time)))
    else
        rand(Uniform(0, 1), dim_count(inst, :time))
    end

    # WAIS

    if wais_calib == "Distribution"
        update_param!(inst, :WAISmodel_uniforms, rand(Uniform(0, 1), dim_count(inst, :time)))
    else
        rand(Uniform(0, 1), dim_count(inst, :time))
    end
end

function getsim_full(inst::Union{ModelInstance, MarginalInstance}, draws::DataFrame, ii::Int64; save_rvs::Bool=true)
    mcres = getsim_base(inst, draws, ii, save_rvs=save_rvs)
    if has_comp(inst, :AMOC)
        mcres[:I_AMOC] = inst[:AMOC, :I_AMOC]
    end
    if has_comp(inst, :OMH)
        mcres[:I_OMH] = inst[:OMH, :I_OMH]
    end
    if has_comp(inst, :AmazonDieback)
        mcres[:I_AMAZ] = inst[:AmazonDieback, :I_AMAZ]
    end

    mcres
end

function simdataframe(model::Union{Model, MarginalModel}, results::Dict{Symbol, Array}, comp::Symbol, name::Symbol)
    if comp == :FAIR
        return results[name]
    elseif comp == :other
        getii = nothing
        if isa(results[:other][1], DataFrame)
            getii = ii -> results[:other][ii]
        elseif isa(results[:other][1][name], DataFrame)
            getii = ii -> (results[:other][ii] == nothing ? nothing : results[:other][ii][name])
        else
            @assert isa(results[:other][1], DataFrame) "simdataframe(..., :other) is not defined for $(typeof(results[:other][1]))"
        end

        ## combine all dataframes together
        df = nothing
        for ii in 1:length(results[:other])
            values = getii(ii)
            if values == nothing
                continue
            end
            mcdf = copy(values)
            mcdf.trialnum .= ii
            if df == nothing
                df = mcdf
            else
                df = vcat(df, mcdf)
            end
        end

        return df
    else
        return simdataframe(model, convert(Vector{Union{Dict{Symbol, Any}, Nothing}}, results[:other]), comp, name)
    end
end

function simdataframe(model::Union{Model, MarginalModel}, results::Vector{Union{Dict{Symbol, Any}, Nothing}}, comp::Symbol, name::Symbol)
    key = Symbol("$(comp)_$(name)")
    if results[1][key] isa Number
        df = DataFrame(trialnum=1:length(results))
        df[!, name] = [(isnothing(results[ii]) ? missing : results[ii][key]) for ii in 1:length(results)]
    else
        dfbase = getdataframe(model, comp, name)
        alldf = []
        for ii in 1:length(results)
            mcdf = dfbase[!, :]
            if isnothing(results[ii])
                mcdf[!, name] .= missing
            elseif isa(results[ii][key], Vector)
                mcdf[!, name] = results[ii][key]
            else
                mcdf[!, name] = vec(transpose(results[ii][key]))
            end
            mcdf.trialnum .= ii
            push!(alldf, mcdf)
        end
        df = vcat(alldf...)
    end
    df
end
