setwd("~/research/tippt/META/analysis/")

library(dplyr)

alldf <- data.frame()
for (rcp in c("1.5-Base", "CP-Base", "NP-Base")) { # "RCP2.6", "RCP4.5", "RCP6",
    print(rcp)
    df1 <- read.csv(paste0("../results/bytimexcountry-SSP2-", rcp, "-NoOMH-temps.csv"))
    df0 <- read.csv(paste0("../results/bytimexcountry-SSP2-", rcp, "-NoTPs-temps.csv"))

    df1.dmg <- read.csv(paste0("../results/bytimexcountry-SSP2-", rcp, "-NoOMH-damages.csv"))
    df0.dmg <- read.csv(paste0("../results/bytimexcountry-SSP2-", rcp, "-NoTPs-damages.csv"))

    df1.gwl <- read.csv(paste0("../results/bytime-SSP2-", rcp, "-NoOMH-gwarm.csv"))
    df0.gwl <- read.csv(paste0("../results/bytime-SSP2-", rcp, "-NoTPs-gwarm.csv"))

    df <- df0 %>% left_join(df1, by=c('time', 'country', 'trialnum'), suffix=c('.no', '.tp')) %>%
        left_join(df0.dmg, by=c('time', 'country', 'trialnum')) %>%
        left_join(df1.dmg, by=c('time', 'country', 'trialnum'), suffix=c('.no', '.tp')) %>%
        left_join(df0.gwl, by=c('time', 'trialnum')) %>%
        left_join(df1.gwl, by=c('time', 'trialnum'), suffix=c('.no', '.tp'))

    alldf <- rbind(alldf, cbind(rcp=rcp, df %>% filter(time %% 5 == 0)))
}

alldf2 <- alldf %>% filter(time %in% c(2025, 2035, 2050, 2100)) %>%
    group_by(rcp, country, time) %>%
    summarize(GWL.no=mean(T_AT.no, na.rm=T), GWL.tpdiff=mean(T_AT.tp - T_AT.no, na.rm=T),
              T.no=mean(T_country.no, na.rm=T), T.tpdiff=mean(T_country.tp - T_country.no, na.rm=T),
              D.no=mean(total_damages_percap_peryear_percent.no, na.rm=T),
              D.tpdiff=mean(total_damages_percap_peryear_percent.tp -
                            total_damages_percap_peryear_percent.no, na.rm=T))

as.data.frame(subset(alldf2, country == 'USA' & time == 2025))

## For dataset
dataset <- rbind(alldf %>% filter(time %in% c(2025, 2035, 2050) & rcp == "RCP4.5"),
                 alldf %>% filter(time %in% c(2050) & rcp == "RCP2.6"),
                 alldf %>% filter(time == 2100 & rcp %in% c("RCP2.6", "RCP4.5", "RCP6")))
save(dataset, file="META-NoOMH-compare.RData")

write.csv(subset(dataset, country == "USA"), "META-NoOMH-NCA6.csv", row.names=F)
