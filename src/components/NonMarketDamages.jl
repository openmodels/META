@defcomp NonMarketDamages begin
    # Variables
    hockey = Variable(index=[time, country])
    lossfactor = Variable(index=[time, country])

    # Parameters
    conspc = Parameter(index=[time, country], unit="2010 USD PPP")
    T_AT = Parameter(index=[time], unit="degC")

    calib_temp = Parameter(default=2.5, unit="degC") # WTP reference temp
    calib_loss = Parameter(default=0.038) # WTP loss @ ref. temp
    wtp_25k = Parameter(default=0.1429636) # Calibrated so WTP 1% of GDP to avoid ref. temp at $25k pc

    function run_timestep(pp, vv, dd, tt)
        catastrophic_temp = sqrt(pp.calib_temp^2 / pp.calib_loss)

        for cc in dd.country
            vv.hockey[tt, cc] = min(log(1 - pp.calib_loss/(1+100*exp(-pp.wtp_25k*pp.conspc[tt, cc]/1000))) / log(1 - (pp.calib_temp/catastrophic_temp)^2), 1)
            vv.lossfactor[tt, cc] = (1 - ((pp.T_AT[tt]/catastrophic_temp)^2 - (pp.T_AT[TimestepIndex(1)]/catastrophic_temp)^2))^vv.hockey[tt, cc]
        end
    end
end

function addNonMarketDamages(model; before=nothing, after=nothing)
    add_comp!(model, NonMarketDamages, first=2010, before=before, after=after)
end
