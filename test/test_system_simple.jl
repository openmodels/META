using Test
include("../src/MimiMETA.jl")

model1 = base_model(rcp="RCP4.5", ssp="SSP2")
run(model1)

model2 = full_model(rcp="RCP4.5", ssp="SSP2")
run(model2)

T_AT1 = model1[:temperature, :T][(2020-1750+1):10:(2200-1750+1)]
T_AT2 = model2[:temperature, :T][(2020-1750+1):10:(2200-1750+1)]

@test all(T_AT1 .!= T_AT2)
