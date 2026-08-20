setwd("~/research/tippt/META/analysis")

library(ggplot2)
library(dplyr)

df <- rbind(cbind(SSP="SSP2-4.5", read.csv("../results/bytime-totalloss.csv")),
            cbind(SSP="SSP5-8.5", read.csv("../results/bytime-totalloss-ssp585.csv")))
df2 <- df %>% group_by(SSP, time) %>% summarize(mu=mean(total_damages_global_peryear_percent), ci5=quantile(total_damages_global_peryear_percent, .05), ci95=quantile(total_damages_global_peryear_percent, .95))
for (year in 2009:1950) {
    df2.hist.ssp245 <- subset(df2, SSP == 'SSP2-4.5' & time == 2010)
    df2.hist.ssp245$time <- year
    df2.hist.ssp585 <- subset(df2, SSP == 'SSP5-8.5' & time == 2010)
    df2.hist.ssp585$time <- year
    df2 <- rbind(df2.hist.ssp245, df2.hist.ssp585, df2)
}

ggplot(df2, aes(time, mu, colour=SSP)) +
    coord_cartesian(xlim=c(2005, 2100)) +
    ##geom_line() + geom_ribbon(aes(ymin=ci5, ymax=ci95), alpha=.5) +
    geom_smooth() +
    theme_bw() + scale_x_continuous(NULL, expand=c(0, 0)) + ylab("Percent reductions in welfare")

df <- read.csv("../results/bytimexcountry-totalloss.csv")
df2 <- df %>% group_by(country, time) %>% summarize(mu=mean(total_damages_percap_peryear_percent), ci5=quantile(total_damages_percap_peryear_percent, .05), ci95=quantile(total_damages_percap_peryear_percent, .95))

library(PBSmapping)

shp <- importShapefile("~/data/political/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
polydata <- attr(shp, 'PolyData')

shp2 <- shp %>% left_join(polydata[, c('PID', 'adm0_a3')] %>% left_join(subset(df2, time == 2050), by=c('adm0_a3'='country')))

library(scales)
ggplot(subset(shp2, PID != 54), aes(X, Y, group=paste(PID, SID))) +
    geom_polygon(aes(fill=pmin(20, pmax(-10, mu)))) +
    coord_map(ylim=c(-51, 58)) + xlab(NULL) + ylab(NULL) +
    theme_bw() + scale_fill_gradient2("% Loss:", low=muted("blue"), high=muted("red"))
