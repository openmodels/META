using DataFrames, CSV
using GlobalSensitivity
using Plots

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
    22:23 => "Burke Damages",
    24:43 => "Interactions",
    44:45 => "OMH",
    46 => "ISM",
    47:48 => "SAF",
    49 => "SLR Damages",
    50:51 => "Sensitivity"
)

titles = Dict{String, String}("easi" => "EASI method", "delta" => "Delta moment method")

for do_gas in ["scc", "scch4"]
    plots = []
    for do_method in ["easi", "delta"]
        println(do_method)

        params = CSV.read("../results/params-$(do_gas)-CP-Base-SSP2-GSA-0.5.csv", DataFrame)

        yy = sccs[sccs.pulse_year .== 2020, do_gas]
        XX = [params[!, names(params) .!= "global$(do_gas)"] DataFrame(Tprime=Tprime[!, "T_$(uppercase(do_gas))"],
                                                                       Tprime2=Tprime2[!, "T_$(uppercase(do_gas))"])]
        keep = [all(.!ismissing.(row)) for row in eachrow(Matrix(XX))]
        XXmat = convert.(Float64, Matrix(XX[keep, :]))'
        # Note: don't include :SLR_*, since it is determined by T_AT and will capture AIS + GIS effects

        if do_method == "easi"
            res = gsa(XXmat, convert.(Float64, yy[keep]), EASI())

            widths = res.S1 ./ sum(res.S1)
        elseif do_method == "delta"
            res = gsa(XXmat, convert.(Float64, yy[keep]), DeltaMoment())

            widths = res.adjusted_deltas ./ sum(res.adjusted_deltas)
        elseif do_method == "reg"
            res = gsa(XXmat, convert.(Float64, yy[keep])', RegressionGSA())
            # FAILS
        end

        updated_widths = Float64[]
        labels = String[]

        for (wedges_range, category) in wedge_to_category
            indices = collect(wedges_range)
            width_sum = sum(widths[indices])
            push!(updated_widths, width_sum)
            push!(labels, category)
        end

        pie(updated_widths, label=labels, title=titles[do_method], legend=:none, linewidth=0.5, c=palette(:tab10))

        for (i, label) in enumerate(labels)
            r = rand() / 2 + 0.5
            theta0 = sum(updated_widths[1:i-1]) + updated_widths[i] / 2
            theta = 2π * theta0 - updated_widths[i] / 2
            x = 1.1 * cos(theta)
            y = 1.1 * sin(theta)
            annotate!([(r * cos(theta), r * sin(theta), text(label, 10, :black, :center))])
        end

        push!(plots, current())
    end

    plot(plots..., layout=(1, 2))
    plot!(size=(600,300))
    Plots.pdf("gsa-$(do_gas).pdf")
end
