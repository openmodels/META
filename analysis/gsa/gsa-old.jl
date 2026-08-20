using Distributions
using DataStructures
using GlobalSensitivityAnalysis

function analyze(model_output::AbstractArray{<:Number, S};
                 conf_level::Union{Nothing, Number} = 0.95,
                 calc_second_order::Bool = true,
                 progress_meter::Bool = true) where S

    # define constants
    N, D = size(model_output) # number of samples, number of uncertain parameters in problem

    # values for CI calculations
    if conf_flag
        r = rand(1:N, N, N)
        Z = quantile(Normal(0.0, 1.0),1 - (1 - conf_level)/2) # calculate z* for CI
    end

    # normalize model output
    model_output = (model_output .- mean(model_output)) ./ std(model_output)

    # separate the model_output into results from matrices "A". "B" and "AB"
    A, B, AB, BA = split_output(model_output, N, D, calc_second_order)

    # preallocate arrays for indices
    firstorder = Array{Float64}(undef, D)
    totalorder = Array{Float64}(undef, D)
    calc_second_order ? secondorder =  fill!(Array{Union{Float64, Missing}}(undef, D, D), missing) : nothing

    # preallocate arrays for confidence intervals
    if conf_flag
        firstorder_conf = Array{Float64}(undef, D)
        totalorder_conf = Array{Float64}(undef, D)
        calc_second_order ? secondorder_conf =  fill!(Array{Union{Float64, Missing}}(undef, D, D), missing) : nothing
    end

    # set up progress meter
    counter = 0
    progress_meter ? p = Progress(D, counter, "Calculating indices for $D parameters ...") : nothing

    for i in 1:D

        # increment progress meter
        counter += 1
        progress_meter ? ProgressMeter.update!(p, counter) : nothing

        # first order and total order indices
        firstorder[i] = first_order(A, AB[:, i], B)[1] # array to scalar with [1]
        totalorder[i] = total_order(A, AB[:, i], B)[1] # array to scalar with [1]

        # first order and total order indice confidence intervals
        conf_flag ? firstorder_conf[i] = Z * std(first_order(A[r], AB[r, i], B[r])) : nothing
        conf_flag ? totalorder_conf[i] = Z * std(total_order(A[r], AB[r, i], B[r])) : nothing

        # second order indices
        if calc_second_order
            for j in (i+1):D
                secondorder[i, j] = second_order(A, AB[:, i], AB[:, j], BA[:, i], B)[1] # array to scalar with [1]
                conf_flag ? secondorder_conf[i,j] = Z * std(skipmissing(second_order(A[r], AB[r, i], AB[r, j], BA[r, i], B[r]))) : nothing
            end
        end
    end

    if calc_second_order
        if conf_flag
            results = Dict(
                :firstorder         => firstorder,
                :firstorder_conf    => firstorder_conf,
                :totalorder         => totalorder,
                :totalorder_conf    => totalorder_conf,
                :secondorder        => secondorder,
                :secondorder_conf   => secondorder_conf
            )
        else
            results = Dict(
                :firstorder         => firstorder,
                :totalorder         => totalorder,
                :secondorder        => secondorder,
            )
        end
    else
        if conf_flag
            results = Dict(
                :firstorder         => firstorder,
                :firstorder_conf    => firstorder_conf,
                :totalorder         => totalorder,
                :totalorder_conf    => totalorder_conf
            )
        else
            results = Dict(
                :firstorder         => firstorder,
                :totalorder         => totalorder,
            )
        end
    end
    return results
end
