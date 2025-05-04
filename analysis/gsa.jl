using DataFrames, CSV
using GlobalSensitivity
using Plots

do_pies = false

sccs = CSV.read("../results/sccs-CP-Base-SSP2-GSA-0.5.csv", DataFrame)
bytime = CSV.read("../results/bytime-CP-Base-SSP2-GSA-0.5.csv", DataFrame)
bytimemore = CSV.read("../results/bytimemore-CP-Base-SSP2-GSA-0.5.csv", DataFrame)

T2010 = bytimemore[bytimemore.time .== 2010, :]
T2009 = bytimemore[bytimemore.time .== 2009, :]
T2008 = bytimemore[bytimemore.time .== 2008, :]

Tprime = T2010 .- T2009
Tprime2 = (T2010 .- T2009) .- (T2009 .- T2008)

wedge_to_category = Dict(
    1:17 => "AIS",
    18:19 => "Amazon",
    20:21 => "AMOC",
    #22:23 => "Burke Damages",
    24:43 => "Interactions",
    44:45 => "OMH",
    46 => "ISM",
    47:48 => "SAF",
    49 => "SLR Damages",
    50:51 => "Sensitivity"
)

function prep_gsa(do_gas)
    params = CSV.read("../results/params-$(do_gas)-CP-Base-SSP2-GSA-0.5.csv", DataFrame)

    yy = sccs[sccs.pulse_year .== 2020, do_gas]
    XX = [params[!, names(params) .!= "global$(do_gas)"] DataFrame(Tprime=Tprime[!, "T_$(uppercase(do_gas))"],
                                                                   Tprime2=Tprime2[!, "T_$(uppercase(do_gas))"])]
    keepobs = [all(.!ismissing.(row)) for row in eachrow(Matrix(XX))]
    keepcol = [!all(col .== 0) for col in eachcol(Matrix(XX[keepobs, :]))]
    XXmat = convert.(Float64, Matrix(XX[keepobs, keepcol]))'
    # Note: don't include :SLR_*, since it is determined by T_AT and will capture AIS + GIS effects

    yyvec = convert.(Float64, yy[keepobs])

    return (yyvec, XXmat, names(XX)[keepcol], keepcol)
end

function get_gsa(yyvec, XXmat, XXnames, do_method)
    if do_method == "easi"
        res = gsa(XXmat, yyvec, EASI())

        DataFrame(param=XXnames, raw=res.S1, lo=res.S1, hi=res.S1)
    elseif do_method == "delta"
        res = gsa(XXmat, yyvec, DeltaMoment())

        DataFrame(param=XXnames, raw=res.adjusted_deltas, lo=res.adjusted_deltas_low, hi=res.adjusted_deltas_hi)
    else
        res = gsa(XXmat, yyvec', RegressionGSA(do_method == "reg-rank"))

        if do_method == "reg-rank"
            partialvar = vec(res.partial_rank_correlation.^2)
        else
            partialvar = vec(res.partial_correlation.^2)
        end
        DataFrame(param=XXnames, raw=partialvar, lo=partialvar, hi=partialvar)
    end
end

function get_category_values(inputs, do_method)
    results = get_gsa(inputs[1], inputs[2], inputs[3], do_method)
    normed_raw = zeros(length(inputs[4]))
    normed_raw[inputs[4]] = results.raw
    normed_lo = zeros(length(inputs[4]))
    normed_lo[inputs[4]] = results.lo
    normed_hi = zeros(length(inputs[4]))
    normed_hi[inputs[4]] = results.hi

    import_raw = Float64[]
    import_lo = Float64[]
    import_hi = Float64[]
    labels = String[]

    for (wedges_range, category) in wedge_to_category
        indices = collect(wedges_range)
        width_sum = sqrt(sum(normed_raw[indices].^2))
        push!(import_raw, width_sum)
        width_sum = sqrt(sum(normed_lo[indices].^2))
        push!(import_lo, width_sum)
        width_sum = sqrt(sum(normed_hi[indices].^2))
        push!(import_hi, width_sum)
        push!(labels, category)
    end

    return import_raw, import_lo, import_hi, labels
end

titles = Dict{String, String}("easi" => "EASI method", "delta" => "Delta moment method",
                              "reg-level" => "Regression method (levels)", "reg-rank" => "Regression method (ranks)")

if do_pies

    for do_gas in ["scc", "scch4"]
        plots = []

        inputs = prep_gsa(do_gas)
        for do_method in ["easi", "delta", "reg-level", "reg-rank"]
            println(do_method)

            import_raw, import_lo, import_hi, labels = get_category_values(inputs, do_method)
            normed_raw = import_raw / sum(import_raw)

            pie(import_raw, label=labels, title=titles[do_method], legend=:none, linewidth=0.5, c=palette(:tab10))

            for (i, label) in enumerate(labels)
                if import_raw[i] > 0
                    r = rand() / 2 + 0.5
                    theta0 = sum(import_raw[1:i-1]) + import_raw[i] / 2
                    theta = 2π * theta0 - import_raw[i] / 2
                    x = 1.1 * cos(theta)
                    y = 1.1 * sin(theta)
                    annotate!([(r * cos(theta), r * sin(theta), text(label, 10, :black, :center))])
                end
            end

            push!(plots, current())
        end

        plot(plots..., layout=(2, 2))
        plot!(size=(600,600))
        Plots.pdf("gsa-$(do_gas).pdf")
    end
else
    markers = Dict{String, Tuple{Symbol,Int64,Float64,Symbol}}(
        "easi" => (:circle, 8, 0.8, :blue),
        "delta" => (:diamond, 8, 0.8, :green),
        "reg-level" => (:square, 8, 0.8, :red),
        "reg-rank" => (:cross, 8, 0.8, :purple))

    for do_gas in ["scc", "scch4"]
        inputs = prep_gsa(do_gas)
        pp = nothing
        for do_method in ["easi", "delta", "reg-level", "reg-rank"]
            println(do_method)
            import_raw, import_lo, import_hi, labels = get_category_values(inputs, do_method)

            if pp == nothing
                pp = plot(
                    import_raw / sum(import_raw), labels, seriestype=:scatter, label=titles[do_method],
                    marker=markers[do_method],
                    xlabel="Variables", ylabel="Relative Importance", legend=:topright)
            elseif all(import_lo .== import_hi)
                plot!(pp, import_raw / sum(import_raw), labels, seriestype=:scatter, label=titles[do_method],
                      marker=markers[do_method])
            else
                for ii in 1:length(labels)
                    plot!(pp, [import_raw[ii] / sum(import_raw)], [labels[ii]], seriestype=:scatter,
                          label=ii == 1 ? titles[do_method] : "",
                          xerror=[((import_raw[ii] - import_lo[ii]) / sum(import_raw), (import_hi[ii] - import_raw[ii]) / sum(import_raw))],
                          marker=markers[do_method], line=(:solid, 2, :purple))
                end
            end
        end

        display(pp)
        plot!(size=(600,300))
        Plots.pdf("gsa-scatter-$(do_gas).pdf")
    end
end
