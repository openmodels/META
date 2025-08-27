using Mimi
@defcomp TotalDamages begin

    # Parameters/input variables
    postdamage_consumption_percap_percountry  = Parameter(index = [time, country], unit = "2010 USD PPP") # Consumption per cap per country post SLR and post temperature damages
    baseline_consumption_percap_percountry    = Parameter(index = [time, country], unit = "2010 USD PPP") # Counterfactual consumption per cap per country from SSPs
    population                                = Parameter(index = [time, country], unit = "inhabitants")
    EMUC                                      = Parameter() # Elasticity of marginal utility of consumption
    lossfactor                                = Parameter(index = [time, country]) # Non-market loss factor for MERGE add-on
    
    # Helper variables
    global_conspc_counterfactual              = Variable(index = [time], unit = "2010 USD PPP") # Global consumption per capita, population-weighted, before climate damages
    population_sanitized                      = Variable(index = [time, country], unit = "inhabitants") # Population with NaNs replaced by zero
    population_global                         = Variable(index = [time], unit = "inhabitants") # Global population
    population_weights                        = Variable(index = [time, country], unit = "Per cent") # Population weights for aggregation
    lossfactor_global                         = Variable(index = [time]) # Global loss factor, from population-weighted country loss factors

    # Market-only damage metrics
    total_damages_percap_peryear              = Variable(index = [time, country], unit = "2010 USD PPP") # Undiscounted total market damages per capita per year per country
    total_damages_percap_peryear_percent      = Variable(index = [time, country], unit = "Per cent") # Undiscounted total market damages per capita per year per country in % of baseline consumption
    total_damages_peryear                     = Variable(index = [time, country], unit = "2010 USD PPP") # Undiscounted total market damages per year per country
    total_damages_cumulative                  = Variable(index = [time, country], unit = "2010 USD PPP") # Country-level undiscounted total market damages through 2200
    total_damages_global_peryear              = Variable(index = [time], unit = "2010 USD PPP") # Undiscounted total market damages per year (global)
    total_damages_global_peryear_percent      = Variable(index = [time]) # Undiscounted total market damages per year in % of baseline consumption (global)
    total_damages_global_cumulative           = Variable(index = [time], unit = "2010 USD PPP") # Undiscounted total market damages through 2200 (global)

    # Market + non-market (full) damage metrics
    total_damages_full_percap_peryear         = Variable(index = [time, country], unit = "2010 USD PPP") # Undiscounted total (market + non-market) damages per capita per year per country
    total_damages_full_percap_peryear_percent = Variable(index = [time, country], unit = "Per cent") # Same as above, in % of baseline consumption
    total_damages_full_peryear                = Variable(index = [time, country], unit = "2010 USD PPP") # Undiscounted total (market + non-market) damages per year per country
    total_damages_full_cumulative             = Variable(index = [time, country], unit = "2010 USD PPP") # Country-level undiscounted total (market + non-market) damages through 2200
    total_damages_full_global_peryear         = Variable(index = [time], unit = "2010 USD PPP") # Undiscounted total (market + non-market) damages per year (global)
    total_damages_full_global_peryear_percent = Variable(index = [time]) # Same as above, in % of baseline consumption (global)
    total_damages_full_global_cumulative      = Variable(index = [time], unit = "2010 USD PPP") # Undiscounted total (market + non-market) damages through 2200 (global)

    # Utility-equivalent damage metrics (equity-weighted)
    utility_equivalent_change                 = Variable(index = [time, country]) # Welfare-equivalent change from climate damages (per capita, per country)
    utility_equivalent_change_global          = Variable(index = [time]) # Welfare-equivalent change from climate damages, population-weighted (equity weighting through utility function)
    total_damages_equiv_conspc_equity         = Variable(index = [time]) # Per-period consumption-equivalent for equity-weighted climate damages

    function run_timestep(pp, vv, dd, tt)

        # Initialise global accumulators
        vv.population_global[tt] = 0.0
        vv.total_damages_global_peryear[tt] = 0.0
        vv.total_damages_global_peryear_percent[tt] = 0.0
        vv.total_damages_full_global_peryear[tt] = 0.0
        vv.total_damages_full_global_peryear_percent[tt] = 0.0
        vv.utility_equivalent_change_global[tt] = 0.0
        vv.global_conspc_counterfactual[tt] = 0.0
        vv.lossfactor_global[tt] = 0.0

        # --- Loop over countries ---
        for cc in dd.country
            # Sanitize population (replace NaN with 0) and store
            vv.population_sanitized[tt, cc] = isnan(pp.population[tt, cc]) ? 0.0 : pp.population[tt, cc]
            vv.population_global[tt] += vv.population_sanitized[tt, cc]

            # --- Market-only damages ---
            vv.total_damages_percap_peryear[tt, cc] = pp.baseline_consumption_percap_percountry[tt, cc] - pp.postdamage_consumption_percap_percountry[tt, cc]
            vv.total_damages_percap_peryear_percent[tt, cc] =
                (isnan(pp.baseline_consumption_percap_percountry[tt, cc]) || pp.baseline_consumption_percap_percountry[tt, cc] == 0) ? 0.0 : vv.total_damages_percap_peryear[tt, cc] / pp.baseline_consumption_percap_percountry[tt, cc] * 100
            vv.total_damages_peryear[tt, cc] = vv.total_damages_percap_peryear[tt, cc] * vv.population_sanitized[tt, cc]
            vv.total_damages_global_peryear[tt] += vv.total_damages_peryear[tt, cc]

            # --- Market + non-market (full) damages ---
            vv.total_damages_full_percap_peryear[tt, cc] = pp.baseline_consumption_percap_percountry[tt, cc] - pp.postdamage_consumption_percap_percountry[tt, cc] * pp.lossfactor[tt, cc]
            vv.total_damages_full_percap_peryear_percent[tt, cc] =
                (isnan(pp.baseline_consumption_percap_percountry[tt, cc]) || pp.baseline_consumption_percap_percountry[tt, cc] == 0) ? 0.0 : vv.total_damages_full_percap_peryear[tt, cc] / pp.baseline_consumption_percap_percountry[tt, cc] * 100
            vv.total_damages_full_peryear[tt, cc] = vv.total_damages_full_percap_peryear[tt, cc] * vv.population_sanitized[tt, cc]
            vv.total_damages_full_global_peryear[tt] += vv.total_damages_full_peryear[tt, cc]

            # --- Utility-equivalent change per capita ---
            vv.utility_equivalent_change[tt, cc] =
                ((1 / (1 - pp.EMUC)) * (max(pp.baseline_consumption_percap_percountry[tt, cc], 1) * pp.lossfactor[tt, cc])^(1 - pp.EMUC)) -
                ((1 / (1 - pp.EMUC)) * (max(pp.postdamage_consumption_percap_percountry[tt, cc], 1) * pp.lossfactor[tt, cc])^(1 - pp.EMUC))
        end

        # --- Population weights and global % aggregates ---
        for cc in dd.country
            vv.population_weights[tt, cc]                    = vv.population_sanitized[tt, cc] / vv.population_global[tt]
            vv.total_damages_global_peryear_percent[tt]      += vv.total_damages_percap_peryear_percent[tt, cc] * vv.population_weights[tt, cc]
            vv.total_damages_full_global_peryear_percent[tt] += vv.total_damages_full_percap_peryear_percent[tt, cc] * vv.population_weights[tt, cc]
            vv.utility_equivalent_change_global[tt]          += vv.utility_equivalent_change[tt, cc] * vv.population_weights[tt, cc]
            vv.global_conspc_counterfactual[tt]              += pp.baseline_consumption_percap_percountry[tt, cc] * vv.population_weights[tt, cc]
            vv.lossfactor_global[tt]                         += pp.lossfactor[tt, cc] * vv.population_weights[tt, cc]
        end

        # --- Equity-weighted consumption equivalent (% change) ---
        vv.total_damages_equiv_conspc_equity[tt] =
            (vv.global_conspc_counterfactual[tt] -
             ((vv.utility_equivalent_change_global[tt] *
               vv.lossfactor_global[tt] * (1 - pp.EMUC)) ^
              round(Int, 1 / (1 - pp.EMUC)))) / vv.global_conspc_counterfactual[tt]

        # --- Cumulative damages (market and full) ---
        if is_first(tt)
            vv.total_damages_global_cumulative[tt]      = vv.total_damages_global_peryear[tt]
            vv.total_damages_full_global_cumulative[tt] = vv.total_damages_full_global_peryear[tt]
            for cc in dd.country
                vv.total_damages_cumulative[tt, cc]      = vv.total_damages_peryear[tt, cc]
                vv.total_damages_full_cumulative[tt, cc] = vv.total_damages_full_peryear[tt, cc]
            end
        else
            vv.total_damages_global_cumulative[tt]      = vv.total_damages_global_cumulative[tt-1] +
                                                           vv.total_damages_global_peryear[tt]
            vv.total_damages_full_global_cumulative[tt] = vv.total_damages_full_global_cumulative[tt-1] +
                                                           vv.total_damages_full_global_peryear[tt]
            for cc in dd.country
                vv.total_damages_cumulative[tt, cc]      = vv.total_damages_cumulative[tt-1, cc] +
                                                           vv.total_damages_peryear[tt, cc]
                vv.total_damages_full_cumulative[tt, cc] = vv.total_damages_full_cumulative[tt-1, cc] +
                                                           vv.total_damages_full_peryear[tt, cc]
            end
        end
    end
end


function addTotalDamages(model)
    params = CSV.read("../data/utilityparams.csv", DataFrame)
    damages = add_comp!(model, TotalDamages, first=2010)
    damages[:EMUC] = params.Value[params.Parameter .== "EMUC"][1]
    damages[:lossfactor] = reshape(ones(dim_count(model, :time) * dim_count(model, :country)),
                                   dim_count(model, :time), dim_count(model, :country))
    damages
end