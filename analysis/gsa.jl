using DataFrames, CSV
using GlobalSensitivity

sccs = CSV.read("../results/sccs-CP-Base-SSP2-NoTPs-default.csv", DataFrame)
params = CSV.read("../results/params-scch4-CP-Base-SSP2-NoTPs-default.csv", DataFrame)
bytime = CSV.read("../results/bytime-scc-CP-Base-SSP2-NoTPs-default.csv", DataFrame)

yy = sccs.scch4[sccs.pulse_year .== 2020]
XX = [params[!, 1:ncol(params)-1] bytime[bytime.time .== 2100, [:T_AT_SCCH4]]]

# Note: don't include :SLR_SCCH4, since it is determined by T_AT and will capture AIS + GIS effects

res = gsa(Matrix(XX)', yy, EASI())

