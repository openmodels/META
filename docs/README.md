Figures
[\[fig:climate_module\]](#fig:climate_module){reference-type="ref"
reference="fig:climate_module"} and
[\[fig:damages_econ_module\]](#fig:damages_econ_module){reference-type="ref"
reference="fig:damages_econ_module"} provide an overview of the model
structure. Figure
[\[fig:climate_module\]](#fig:climate_module){reference-type="ref"
reference="fig:climate_module"} provides a schematic diagram of the
climate module. The inputs to the climate module are greenhouse gas
(GHG) emissions from exogenous scenarios; the output is the change in
global mean surface temperature (GMST). Three tipping points provide
positive feedbacks from the increase in GMST to GHG emissions (the
permafrost carbon feedback, dissociation of ocean methane hydrates, and
Amazon rainforest dieback), while one provides a positive feedback from
the increase in GMST to radiative forcing (Arctic sea-ice loss/surface
albedo feedback).

Figure
[\[fig:damages_econ_module\]](#fig:damages_econ_module){reference-type="ref"
reference="fig:damages_econ_module"} provides a schematic diagram of the
damages/economic module. The input to the damages/economic module is the
change in GMST from the climate module. The output is discounted
utility/social welfare. Slowdown of the Atlantic Meridional Overturning
Circulation modulates the relationship between global and national mean
temperature change. Disintegration of the Greenland and Antarctic Ice
Sheets increases sea level rise. Variability of the Indian summer
monsoon directly impacts GDP in India due to droughts and floods.

![image](Figures/Climate model with TPs FaIR.jpg){width="15cm"}
[]{#fig:climate_module label="fig:climate_module"}

![image](Figures/Damages_plus_TPs 2023.jpg){width="15cm"}
[]{#fig:damages_econ_module label="fig:damages_econ_module"}

[]{#sec:PCF label="sec:PCF"}

Our model of the permafrost carbon feedback (PCF) is taken from
[@kessler2017estimating]. This is a tractable model that mimics in
reduced form the physical-science literature quantifying permafrost
carbon release by simulating two stages: (i) permafrost thaw as a
function of rising temperatures and (ii) decomposition of thawed
permafrost, leading to the release of CO$_{2}$ or CH$_{4}$. Kessler
built the model for incorporation in DICE and, although we don't use
DICE, the level of abstraction from the underlying physical processes is
well suited to our approach. Despite the level of abstraction, however,
the model retains enough structure to be directly calibrated on
estimates reported in the underlying literature.

In the first stage, near-surface permafrost thaw is a linear function of
warming relative to time zero:
$$\textrm{PF}_{\textrm{extent}}(t)=1-\beta_{\textrm{PF}}\left[\Delta \overline{T_{\textrm{AT}}}(t)-\Delta \overline{T_{\textrm{AT}}}(0)\right],\label{eq:PF_extent}$$
where
$\textrm{PF}_{\textrm{extent}}(t)\equiv\textrm{PF}_{\textrm{area}}(t)/\textrm{PF}_{\textrm{area}}(0)$,
i.e., $\textrm{PF}_{\textrm{extent}}(t)$ is the area of permafrost
remaining at time $t$ relative to time zero,
$\Delta \overline{T_{\textrm{AT}}}$ is the global mean surface air
temperature relative to pre-industrial, and $\beta_{\textrm{PF}}$ is a
coefficient representing the sensitivity of permafrost thaw to
temperature, which Kessler calibrated by regressing estimates of thaw on
temperature from the literature. $t=0$ in our model is the year 2010.

The amount of carbon in freshly thawed permafrost at time $t$,
$C_{\textrm{thawedPF}}$, is then the product of the total stock of
carbon locked in the near-surface northern circumpolar permafrost
region, $C_{\textrm{PF}}$, and the area of permafrost freshly thawed:
$$C_{\textrm{thawedPF}}(t)=-C_{\textrm{PF}}\left[\textrm{PF}_{\textrm{extent}}(t)-\textrm{PF}_{\textrm{extent}}(t-1)\right].\label{eq:C_thawedPF}$$
Once thawed, the principal way in which carbon is released to the
atmosphere is microbial decomposition and this happens slowly. Some of
the carbon is released as CO$_{2}$ and some as CH$_{4}$. Kessler's model
divides the stock of thawed carbon into a passive reservoir that
releases no carbon and an active reservoir that decomposes exponentially
and releases CO$_{2}$ and CH$_{4}$ in fixed proportion. Therefore,
cumulative CO$_{2}$ emissions to the atmosphere from thawed permafrost,
$\textrm{CCum}_{\textrm{PF}}$, are given by
$$\textrm{CCum}_{\textrm{PF}}(t)=\sum_{s=0}^{t}C_{\textrm{thawedPF}}(s)\left(1-\textrm{propPassive}\right)\left(1-e^{(-t-s)/\tau}\right),\label{eq:CCum_PF}$$
where propPassive is the proportion of thawed permafrost in the passive
reservoir and $\tau$ is the e-folding time of permafrost decomposition
in the active reservoir, which is multiple decades (see below). The
fluxes of CO$_{2}$ and CH$_{4}$ are respectively given by

$$\begin{aligned}
\textrm{CO}{}_{\textrm{2\_PF}}(t) & = & (1-\textrm{propCH}_{\textrm{4}})\left[\textrm{\ensuremath{\textrm{CCum}_{\textrm{PF}}}}(t)-\textrm{\ensuremath{\textrm{CCum}_{\textrm{PF}}}}(t-1)\right],\label{eq:CO_2PF}\\
\textrm{CH}{}_{\textrm{4\_PF}}(t) & = & (\textrm{propCH}_{\textrm{4}})\left[\textrm{\ensuremath{\textrm{CCum}_{\textrm{PF}}}}(t)-\textrm{\ensuremath{\textrm{CCum}_{\textrm{PF}}}}(t-1)\right],\label{eq:CH_4PF}\end{aligned}$$
where $\textrm{propCH}_{\textrm{4}}$ is the share of CH$_{4}$ emissions
in total carbon emissions.

We can directly reproduce the permafrost carbon emissions estimated by
[@kessler2017estimating] just by imputing her reported parameter values
for $\beta_{\textrm{PF}}$, $C_{\textrm{PF}}$, propPassive, $\tau$ and
$\textrm{propCH}_{\textrm{4}}$ into Equations
([\[eq:PF_extent\]](#eq:PF_extent){reference-type="ref"
reference="eq:PF_extent"})-([\[eq:CH_4PF\]](#eq:CH_4PF){reference-type="ref"
reference="eq:CH_4PF"}). In addition, we use this model to fit the
results of the two other papers contributed to the IAM literature on the
PCF, namely [@hope2016economic] and [@yumashev2019climate].
[@hope2016economic] coupled the PAGE09 IAM to the SiBCASA model of the
PCF. [@yumashev2019climate] developed a new version of the PAGE IAM
called PAGE-ICE, which includes a representation of the PCF calibrated
both on SiBCASA and another PCF model called JULES. We first obtain
estimates of permafrost CO$_{2}$ emissions from each paper as a function
of temperature, and then minimise the sum of squared residuals between
these papers' estimates and estimates from Kessler's model, using four
of the free parameters in Kessler's model, i.e. $\beta_{\textrm{PF}}$,
$C_{\textrm{PF}}$, propPassive, and $\tau$, each parameter restricted to
lie within physically plausible bounds. Table
[1](#tab:PCFmodelparms){reference-type="ref"
reference="tab:PCFmodelparms"} reports the various parameter values.
Figure [2](#fig:PCFfits){reference-type="ref" reference="fig:PCFfits"}
shows the fit to cumulative CO$_{2}$ emissions from [@hope2016economic]
and [@yumashev2019climate]. CH$_{4}$ emissions for these two papers are
obtained simply by using the fitted parameters in combination with the
fixed value of $\textrm{propCH}_{\textrm{4}}$ from
[@kessler2017estimating].

::: centering
::: {#tab:PCFmodelparms}
  ------------------------- -------------- ------------- --------------------- ------------------------
                             Kessler main   Lower/upper         Fit of                  Fit of
                                spec.         bounds      [@hope2016economic]   [@yumashev2019climate]
           $\beta$              0.172           0/1              0.066                  0.085
   $C_{\textrm{PF}}$ (GtC)       1035        885/1185            1160                    1066
         propPassive             0.40        0.29/0.51           0.37                    0.41
       $\tau$ (years)             70           0/200              31                      66
  ------------------------- -------------- ------------- --------------------- ------------------------

  : PCF model parameter values
:::
:::

::: center
![Fit of cumulative permafrost CO$_{2}$ emissions from
[@hope2016economic], top panel, and [@yumashev2019climate], bottom
panel](Figures/Hope_Schaefer_PCF_fit.pdf){#fig:PCFfits width="75%"}

![Fit of cumulative permafrost CO$_{2}$ emissions from
[@hope2016economic], top panel, and [@yumashev2019climate], bottom
panel](Figures/Yumashev_et_al_PCF_fit.pdf){#fig:PCFfits width="75%"}
:::

[]{#sec:OMH label="sec:OMH"}

There have been two studies of the economic cost of destabilization of
ocean methane clathrates/hydrates. The first is [@whiteman2013climate],
who implemented what-if scenarios in PAGE09, releasing a pulse of
CH$_{4}$ emissions of fixed size and duration into the model at a given
point in time. These scenarios were based on the work of
[@shakhova2010predicted] on hydrates locked within subsea permafrost on
the East Siberian Arctic shelf. [@whiteman2013climate] implemented
various scenarios. Most of their scenarios involved injecting
50GtCH$_{4}$ in total over periods of 10 to 30 years, starting at
different times from 2015 to 2035.[^1] The other study is
[@ceronsky2011checking]. They implemented three what-if scenarios, in
which pulses of CH$_{4}$ emissions from the reservoir of CH$_{4}$
distributed globally on continental shelves and slopes were released in
the FUND IAM. These emissions pulses all commence in 2050 and comprise
permanent flows of 0.2GtCH$_{4}$ per year, 1.784GtCH$_{4}$/yr and
7.8GtCH$_{4}$/yr respectively.

In order to incorporate these studies in our analysis, their what-if
scenarios need to be assigned probabilities. To do this, we use the
framework of survival analysis, treating each emissions pulse as a
hazard event and assigning it a hazard rate, i.e. the conditional
probability that the event will occur in a particular year, given the
temperature in that year and that the event has not occurred previously.
This is both convenient, and conforms with the way some of the other
studies we synthesise treat tipping points, e.g., on Amazon rainforest
dieback [@cai2016risk]. Once triggered, each CH$_{4}$ emissions pulse of
given size lasts its pre-specified amount of time. In general, we can
write the flow of CH$_{4}$ emissions from dissociation of ocean methane
hydrates at time $t$, $\textrm{CH}{}_{\textrm{4\_OMH}}(t)$, as
$$\begin{aligned}
\textrm{CH}{}_{\textrm{4\_OMH}}(t)=\left(\dfrac{\overline{\textrm{CH}{}_{\textrm{4\_OMH}}}}{\Delta_{\textrm{OMH}}}\right)I_{\textrm{OMH}}(t) & \iff & \sum_{s=0}^{t-1}\textrm{CH}{}_{\textrm{4\_OMH}}(s)<\overline{\textrm{CH}{}_{\textrm{4\_OMH}}},\label{eq:CH_4OMHbelowthresh}\\
\textrm{CH}{}_{\textrm{4\_OMH}}(t)=0 & \Longleftarrow & \sum_{s=0}^{t-1}\textrm{CH}{}_{\textrm{4\_OMH}}(s)=\overline{\textrm{CH}{}_{\textrm{4\_OMH}}},\label{eq:CH_4OMHatthresh}\end{aligned}$$
where $\overline{\textrm{CH}{}_{\textrm{4\_OMH}}}$ is the pre-specified
total amount of methane released, e.g., 50Gt in the case of the main
specification of [@whiteman2013climate], and $\Delta_{\textrm{OMH}}$ is
the duration of the release, e.g., 10 years. Applying this formalism to
[@ceronsky2011checking],
$\overline{\textrm{CH}{}_{\textrm{4\_OMH}}}/\Delta_{\textrm{OMH}}\in\left\{ 0.2,1.784,7.8\right\}$
and total CH$_{4}$ released from ocean CH$_{4}$ hydrates is bounded only
by the product of
$\overline{\textrm{CH}{}_{\textrm{4\_OMH}}}/\Delta_{\textrm{OMH}}$ and
the model horizon, i.e. the inequality constraint in Equations
([\[eq:CH_4OMHbelowthresh\]](#eq:CH_4OMHbelowthresh){reference-type="ref"
reference="eq:CH_4OMHbelowthresh"}) and
([\[eq:CH_4OMHatthresh\]](#eq:CH_4OMHatthresh){reference-type="ref"
reference="eq:CH_4OMHatthresh"}) does not bind. $I_{\textrm{OMH}}(t)$ is
an indicator function taking a value of zero before the hazard event is
triggered and one thereafter. In general, its transition function is
$$I_{\textrm{OMH}}(t)=f\left[I_{\textrm{OMH}}(t-1),\Delta \overline{T_{\textrm{AT}}}(t),\varepsilon(t)\right],$$
where $\varepsilon(t)$ is an i.i.d. random shock. That is, in each
period the value of $I_{\textrm{OMH}}$ depends on its own value in the
previous period, the current atmospheric temperature, and the random
shock. Specifically, the probability transition matrix for
$I_{\textrm{OMH}}(t)$ is $$\left[\begin{array}{cc}
1-p_{\textrm{OMH}}(t) & p_{\textrm{OMH}}(t)\\
0 & 1
\end{array}\right],\label{eq:OMHtransitionmatrix}$$ where
$p_{\textrm{OMH}}(t)$ is the probability that the CH$_{4}$ emissions
pulse is triggered in year $t$. This is given by
$$p_{\textrm{OMH}}(t)=1-\exp\left[-b_{\textrm{OMH}}\Delta \overline{T_{\textrm{AT}}}(t)\right],\label{eq:p_OMH}$$
where $b_{\textrm{OMH}}$ is the hazard rate.

In order to calibrate the hazard rate, we use the study of
[@archer2009ocean], which presents a global model of CH$_{4}$ hydrates
on continental shelves and slopes and the release of CH$_{4}$ as
temperatures rise. Their study shows the sensitive dependence of ocean
CH$_{4}$ release on a critical bubble volume fraction threshold. That
is, when ocean CH$_{4}$ hydrates melt, it is uncertain whether the
CH$_{4}$ escapes the ocean sediment into the ocean.[^2] Colder
temperatures closer to the sea floor and chemical reactions (anaerobic
oxidation by bacteria and archaea) both effectively trap the CH$_{4}$
from escaping. The more CH$_{4}$ is in bubbles, however, the more likely
it is to escape. In the model of [@archer2009ocean], the bubble volume
upon melting of the hydrates must exceed the critical bubble volume
fraction in order for the CH$_{4}$ to be released. Calibrating the
hazard rate on [@archer2009ocean] means that we re-interpret
[@whiteman2013climate] in the context of the global reservoir of
CH$_{4}$ hydrates on continental shelves and slopes, rather than the
reservoir of CH$_{4}$ locked in subsea permafrost in the Arctic region.
This is justified, since other research suggests a large release of
CH$_{4}$ from the Arctic subsea permafrost within the next two centuries
is extremely unlikely [@archer_model_2015].[^3]

According to [@archer2009ocean], cumulative CH$_{4}$ released in very
long-run equilibrium upon 1$^{\circ}$C warming varies hugely from about
10GtCH$_{4}$ to 541GtCH$_{4}$ for critical bubble fractions of 10% and
1% respectively.[^4] Upon 3$^{\circ}$C warming the range increases to
about 32-1084Gt. Moreover, [@archer2009ocean] report that there is next
to no empirical evidence on the critical bubble fraction. In the absence
of such evidence, we try three alternative specifications of the
probability distribution of equilibrium cumulative CH$_{4}$ release as a
function of the critical bubble fraction (Table
[2](#tab:b_OMH){reference-type="ref" reference="tab:b_OMH"}). The
uniform distribution is an application of the principle of insufficient
reason. The triangular and especially the beta distribution are more
conservative in the sense of assigning more probability mass to higher
critical bubble fractions and in turn lower equilibrium CH$_{4}$
releases.

Irrespective of the critical bubble fraction, CH$_{4}$ released from
melting ocean hydrates is thought to take a very long time to reach the
atmosphere, much longer than permafrost carbon. Therefore, in order to
convert the equilibrium CH$_{4}$ release into a transient release, we
conservatively assume a release rate of just 0.2%, implying an e-folding
time of 500 years and approximately 3,000 years for equilibrium to be
reached [also see @archer2009ocean].

The procedure for calibrating the hazard rate $b_{\textrm{OMH}}$ has
been modifed as part of the META model update for this paper. For a
given GMST scenario, the approach just described to represent the
modelling results of [@archer2009ocean] gives us the probability of a
cumulative CH$_{4}$ release of given volume in a given year. For
example, on the mid-range RCP4.5 scenario of the Intergovernmental Panel
on Climate Change (IPCC), fed into our climate module excluding tipping
points, the middle scenario from [@whiteman2013climate] of a cumulative
release of 50GtCH$_{4}$ over 20 years from 2015 to 2035 has a
probability of 24.4%, assuming a beta distribution over critical bubble
fractions. The corresponding hazard rate $b_{\textrm{OMH}}$ is then the
value that, given GMST of 1.07$^{\circ}$C above pre-industrial in the
initial release year of 2015 (also on RCP4.5), triggers the 50GtCH$_{4}$
release with 24.4% probability. In this example,
$b_{\textrm{OMH}}=0.059$. We follow the same procedure to assign hazard
rates using the uniform and triangular distributions, and apply it to
different durations of emissions pulse investigated by
[@whiteman2013climate], as well as the scenarios in
[@ceronsky2011checking]. Table [2](#tab:b_OMH){reference-type="ref"
reference="tab:b_OMH"} reports all the estimated hazard rates. We prefer
the beta distributions except in sensitivity analysis, as they are more
conservative.

::: {#tab:b_OMH}
                                                                               uniform   triangular   beta
  ------------------------------------------------------ -------------------- --------- ------------ -------
  [@whiteman2013climate] 50GtCH$_{4}$ by 2035             $p_{\textrm{OMH}}$    95.3%      90.2%      24.4%
                                                          $b_{\textrm{OMH}}$    0.648      0.491      0.059
  [@whiteman2013climate] 50GtCH$_{4}$ by 2025             $p_{\textrm{OMH}}$    86.4%       8.9%      12.0%
                                                          $b_{\textrm{OMH}}$    0.422      0.020      0.027
  [@whiteman2013climate] 50GtCH$_{4}$ by 2045             $p_{\textrm{OMH}}$    97.7%      97.8%      33.0%
                                                          $b_{\textrm{OMH}}$    0.801      0.811      0.084
  [@ceronsky2011checking] 0.2GtCH$_{4}$/yr 2050-2200      $p_{\textrm{OMH}}$    100%        100%      67.1%
                                                          $b_{\textrm{OMH}}$    0.133      0.205      0.019
  [@ceronsky2011checking] 1.784GtCH$_{4}$/yr 2050-2200    $p_{\textrm{OMH}}$    99.7%       100%      52.4%
                                                          $b_{\textrm{OMH}}$    0.096      0.131      0.013
  [@ceronsky2011checking] 7.8GtCH$_{4}$/yr 2050-2200      $p_{\textrm{OMH}}$    98.5%      99.2%      39.1%
                                                          $b_{\textrm{OMH}}$    0.071      0.081      0.008

  : Calibration of OMH hazard rate, $b_{\textrm{OMH}}$. Triangular
  distribution assumes modal critical bubble fraction of 10%, supports
  of 1% and zero CH$_{4}$ release. Beta distribution assigns cumulative
  probabilities of 0.67, 0.9, 0.95, 0.99 and 1 to critical bubble
  fractions of 10%, 7.5%, 5%, 2.5% and 1% respectively.
:::

[]{#tab:b_OMH label="tab:b_OMH"}

[]{#sec:AMAZ label="sec:AMAZ"}

Dieback of the Amazon rainforest was included in the study of
[@cai2016risk] as a carbon-cycle feedback. This is the study we
incorporate in our analysis. Naturally a wide range of other
economically important consequences of Amazon rainforest dieback are
thereby excluded, including those on biodiversity, ecosystems, and
precipitation patterns. These have yet to be incorporated in any
economic modelling study, to the best of our knowledge.

As mentioned above, [@cai2016risk] model tipping points through survival
analysis. In the case of Amazon rainforest dieback, 50GtC is released
over 50 years upon triggering the hazard event. Using parallel formalism
to ocean methane hydrates, CO$_{2}$ emissions from Amazon rainforest
dieback at time $t$, $\textrm{CO}{}_{\textrm{2\_AMAZ}}(t)$, are given by
$$\begin{aligned}
\textrm{CO}{}_{\textrm{2\_AMAZ}}(t)=\left(\dfrac{\overline{\textrm{CO}{}_{\textrm{2\_AMAZ}}}}{\Delta_{\textrm{AMAZ}}}\right)I_{\textrm{AMAZ}}(t) & \iff & \sum_{s=0}^{t-1}\textrm{CO}{}_{\textrm{2\_AMAZ}}(s)<\overline{\textrm{CO}{}_{\textrm{2\_AMAZ}}},\label{eq:CO_2AMAZbelowthresh}\\
\textrm{CO}{}_{\textrm{2\_AMAZ}}(t)=0 & \Longleftarrow & \sum_{s=0}^{t-1}\textrm{CO}{}_{\textrm{2\_AMAZ}}(s)=\overline{\textrm{CO}{}_{\textrm{2\_AMAZ}}},\label{eq:CO_2AMAZatthresh}\end{aligned}$$
where $\overline{\textrm{CO}{}_{\textrm{2\_AMAZ}}}=50$GtC and
$\Delta_{\textrm{AMAZ}}=50$ years. The probability of the indicator
function $I_{\textrm{AMAZ}}(t)$ transitioning from zero to one is
$$p_{\textrm{AMAZ}}(t)=1-\exp\left[-b_{\textrm{AMAZ}}\Delta \overline{T_{\textrm{AT}}}(t)-1\right],\label{eq:p_AMAZ}$$
where the hazard rate $b_{\textrm{AMAZ}}=0.00163$ in [@cai2016risk] is
taken from the expert elicitation study of [@kriegler2009imprecise].

[]{#sec:GIS label="sec:GIS"}

Our model of disintegration of the Greenland Ice Sheet (GIS) is based on
[@nordhaus2019economics], which follows an approach conceptually similar
to Kessler's ([-@kessler2017estimating]) PCF model by building a simple,
reduced-form process model of GIS disintegration for incorporation in
DICE.[^5] The GIS model is calibrated on results from the underlying
literature modelling ice-sheet dynamics. At the heart of the GIS model
is the very long-run equilibrium relationship between atmospheric
temperature and the volume of the GIS. Assuming this is reversible,
[@nordhaus2019economics] specified
$$\overline{\Delta T_{\textrm{GIS}}^{\ast}}(t)=\Delta \overline{T_{\textrm{GIS\_MAX}}}\left[1-V_{\textrm{GIS}}(t)\right],\label{eq:T^=00007Bstar=00007D_GIS}$$
where $\Delta \overline{T_{\textrm{GIS}}^{\ast}}(t)$ is defined as the
atmospheric temperature increase relative to initial temperature that is
associated with a particular degree of melting of the GIS in equilibrium
and $V_{\textrm{GIS}}(t)\in\left[0,1\right]$ is the volume of the GIS
expressed as a fraction of the initial volume.[^6] In Nordhaus' main
specification,
Eq. ([\[eq:T\^=00007Bstar=00007D_GIS\]](#eq:T^=00007Bstar=00007D_GIS){reference-type="ref"
reference="eq:T^=00007Bstar=00007D_GIS"}) was calibrated on
paleoclimatic data from [@alley2010history], which gives
$\Delta \overline{T_{\textrm{GIS\_MAX}}}=3.4$ and implies that the GIS
is fully melted in equilibrium when the global mean surface temperature
is 3.4$^{\circ}$C above pre-industrial. If [@robinson2012multistability]
is used for calibration instead,
$\Delta \overline{T_{\textrm{GIS\_MAX}}}=1.8$.[^7] An alternative, cubic
specification of the equilibrium temperature-volume relationship allows
for hysteretic behaviour. Fitted on [@alley2010history], this is given
by
$$\Delta \overline{T_{\textrm{GIS}}^{\ast}}(t)=\Delta \overline{T_{\textrm{GIS\_MAX}}}-20.51V_{\textrm{GIS}}(t)+51.9\left[V_{\textrm{GIS}}(t)\right]^{2}-34.79\left[V_{\textrm{GIS}}(t)\right]^{3}.\label{eq:T^=00007Bstar=00007D_GIS_hysteresis}$$
Nordhaus ([-@nordhaus2019economics]) showed that the change in
specification makes little difference on the optimal emissions path,
which involves relatively limited warming, but can make a difference on
high-emissions scenarios.

The difference equation for $V_{\textrm{GIS}}(t)$, i.e. the GIS melt
rate, can be written as $$\begin{aligned}
V_{\textrm{GIS}}(t)-V_{\textrm{GIS}}(t-1) & = &\beta_{GIS}\textrm{sgn}\left[\Delta \overline{T_{\textrm{AT}}}(t-1)-\Delta \overline{T_{\textrm{GIS}}^{\ast}}(t-1)\right]\times \nonumber\\
& & \times\left[\Delta \overline{T_{\textrm{AT}}}(t-1)-\Delta \overline{T_{\textrm{GIS}}^{\ast}}(t-1)\right]^{2}V_{\textrm{GIS}}(t-1)^{0.2},\label{eq:V_GIS_motion}\end{aligned}$$
where $\beta_{GIS}=-0.0000106$ based on regression analysis of estimates
from [@robinson2012multistability].[^8] The basic idea embodied in
Eq. ([\[eq:V_GIS_motion\]](#eq:V_GIS_motion){reference-type="ref"
reference="eq:V_GIS_motion"}) is that melting of the GIS depends on the
difference between the actual atmospheric temperature and the
equilibrium GIS temperature, as well as the volume of the GIS at the
time.

Sea level rises linearly in response to GIS melt,
$$SLR_{\textrm{GIS}}(t)=7\left[1-V_{\textrm{GIS}}(t)\right],\label{eq:SLR_GIS}$$
where $SLR_{\textrm{GIS}}$ is defined relative to the year 2000. This
implies that complete disintegration of the GIS would increase global
mean sea level by 7 metres.

[]{#sec:WAIS label="sec:WAIS"}

In the latest version of META, melting of the Antarctic Ice Sheet (AIS)
is based on a module developed by [@dietzkoninx2022]. This takes a
process-based approach. The contribution of the AIS to SLR is divided
into the surface mass balance (SMB) contribution and the dynamic
contribution. SMB is the balance of surface mass accumulation
(precipitation) and ablation (melting) on the ice sheet. Dynamic
contributions come from the physical transportation of grounded ice into
the ocean through glacier flow. Once afloat, this ice contributes to SLR
through the displacement of water. Dynamic contributions are much more
important than SMB on the AIS [@garbe2020hysteresis].

SMB is modelled using a simple, adjusted linear relationship between SMB
and global mean temperature change. The unadjusted annual mass change
$\Delta\textrm{SMB}$ is given by
$$\Delta\textrm{SMB}=\gamma\left(t-t_0 \right) ^{-0.1}\Delta A(t),\label{eq:unadjusted_SMB}$$
where $t_0$ is 2010 and $\gamma=7.95$mm/yr [@frieler2015consistent].
$\Delta A(t)$ is the change in continental-scale accumulation from 2010,
which is given by
$$\Delta A(t) = \varphi\omega\left[\Delta \overline{T_{\textrm{AT}}}(t) - \Delta \overline{T_{\textrm{AT}}}(0) \right],\label{eq:delta_accumulation}$$
where $\varphi$ is a temperature scaling coefficient of 1.2 that
converts $\Delta \overline{T_{\textrm{AT}}}(t)$ into continental-scale
temperature change based on the modelling of [@garbe2020hysteresis], and
$\omega$ is the change in continental accumulation per degree of
Antarctic warming, estimated by [@frieler2015consistent] at
approximately 5 +/- 1% per degree warming. We calibrate a normal
distribution with a mean of 5% and a standard deviation of 0.4
percentage points.

Equations
[\[eq:unadjusted_SMB\]](#eq:unadjusted_SMB){reference-type="eqref"
reference="eq:unadjusted_SMB"} and
[\[eq:delta_accumulation\]](#eq:delta_accumulation){reference-type="eqref"
reference="eq:delta_accumulation"} permit estimation of the
snowfall-induced mass gain for any scenario of global mean temperature
change, without needing to rely on runs of a complex ice sheet model.
However, [@frieler2015consistent] only analysed the relationship for
continental-scale warming of up to 5$^{\circ}$C above pre-industrial and
temperatures could increase to the extent that SMB in Antarctica turns
negative. [@garbe2020hysteresis] report that the SMB of the ice sheet
will turn negative at approx. 7$^{\circ}$C warming. To account for this,
we model an evolving adjustment factor based on a generalized logistic
function:
$$\textrm{Adjustment}(t)=\frac{K-\Delta \textrm{SMB}(t)}{\left( C+Qe^{-B(t)} \right)^{1/V}},$$
where $K$, $C$, $Q$ and $V$ are constants, and
$B(t)=\left[ \Delta \overline{T_{\textrm{AT}}}(t)-6.75 \right]$. $K$ is
calibrated so that the SMB contribution approaches a maximum of 8mm/yr
at very high temperatures. This value follows the prognosis from
[@garbe2020hysteresis] that, above c. 7$^{\circ}$C warming, the AIS is
committed to losing 70% of its mass via the surface elevation feedback.
Seventy percent of AIS mass is equivalent to c. 40m of SLR and taking a
rapid deglaciation of approximately 5,000 years yields a maximum of
8mm/yr SLR.

Combining
[\[eq:unadjusted_SMB\]](#eq:unadjusted_SMB){reference-type="eqref"
reference="eq:unadjusted_SMB"} and
[\[eq:delta_accumulation\]](#eq:delta_accumulation){reference-type="eqref"
reference="eq:delta_accumulation"} with the adjustment factor and
cumulating over time yields the adjusted total mass change:
$$\widehat{\textrm{SMB}}(t)=\sum_{s=0}^{t} \left[ \Delta \textrm{SMB}(s)+\frac{K-\Delta \textrm{SMB}(s)}{\left( C+Qe^{-B(s)} \right)^{1/V}} \right].\label{eq:SMB_AIS}$$

Dynamic contributions to SLR from the AIS are modelled using the
reduced-form model of [@levermann2020projecting], which is designed to
emulate basal ice shelf melting and the resulting contribution of the
AIS to SLR in 16 state-of-the-art ice sheet models. The five major ice
basins on the continent are modelled separately: East Antarctica, the
Ross Sea, the Amundsen Sea, the Weddell Sea, and the Antarctic
Peninsula. This is because the dynamic discharge of one basin minimally
affects the dynamic discharge of another. The first step is to translate
$\Delta \overline{T_{\textrm{AT}}}$ into subsurface oceanic warming at
the mean depth of the ice shelf base in each of the five basins:
$$\Delta T_0 (r,t)=\beta (r)\Delta\overline{T_{\textrm{AT}}}\left(t-\delta(r)\right).\label{eq:subsurface_ocean_warming}$$
[@levermann2020projecting] derived the scaling coefficients $\beta(r)$
and time-delays $\delta(r)$ from 19 CMIP5 models. Each region of
Antarctica thus has 19 possible pairs of scaling coefficients and time
delays, drawn at random with equal probability. If $t=2050$ and
$\delta(r)=30$ years, for example, then the input to Equation
[\[eq:subsurface_ocean_warming\]](#eq:subsurface_ocean_warming){reference-type="eqref"
reference="eq:subsurface_ocean_warming"} is
$\Delta\overline{T_{\textrm{AT}}}$ in 2020.

The second step is to map subsurface ocean warming into enhanced basal
ice shelf melting: $$\Delta M(r,t)=\lambda \Delta T_0 (r,t),$$ where the
basal melt sensitivity parameter $\lambda$ is randomly chosen from a
uniform distribution with lower and upper bounds of 7ma$^{-1}$K$^{-1}$
and 16ma$^{-1}$K$^{-1}$ respectively. This interval corresponds to
values from experimental observations.

The third step translates the enhanced basal ice shelf melting into ice
loss/SLR. This utilises reduced-form response functions, which
[@levermann2020projecting] estimated on the behaviour of the 16 ice
sheet models. Each ice sheet model was initially subjected to a control
run from 1900 to 2100. In this control run, the models were forced with
historically observed basal ice shelf melting until 2010 and constant
forcing thereafter. After the control run, each ice sheet model was then
subjected to an artificial external forcing experiment involving an
additional stepwise increase of 8m/yr of basal ice shelf melting. The
difference in the dynamic contribution to SLR between the experiment and
the control run forms the basis of the response function for the
particular model and region. The approach assumes that increasing the
magnitude of the forcing by a specific factor will increase the
magnitude of the response of the ice sheet by the same factor. However,
the temporal evolution of the response is not a linear function of time.
Response functions can capture the irregular oscillations of ice sheet
dynamics in response to external forcing. One must also assume that over
the forcing period the five regions of Antarctica respond independently.
[@levermann2020projecting] showed this is a good assumption.
[@levermann2020projecting] also subjected the 16 ice sheet models to
forcing experiments of 4m/yr and 16m/yr of additional basal melting and
compared these responses to the main 8m/yr experiment. Generally, there
was good agreement between the responses to the step increases of
different size. SLR from dynamic processes $S$ is given by
$$S(r,t)=\sum_{r=1}^{5} \sum_{s=0}^{t} \Delta M(r,s) R(r,s),\label{eq:AIS_dynamic}$$
where $R$ is the value of the response function at time $s$, drawn at
random from the set of 16 models. The total Antarctic SLR contribution
is the sum of [\[eq:SMB_AIS\]](#eq:SMB_AIS){reference-type="eqref"
reference="eq:SMB_AIS"} and
[\[eq:AIS_dynamic\]](#eq:AIS_dynamic){reference-type="eqref"
reference="eq:AIS_dynamic"}.

[@levermann2020projecting] derived response functions for the period
1900 to 2100. The period to 2100 is long enough for many of our purposes
in this paper, but not for estimating the social cost of CO$_2$, as a
large portion of the current social cost of CO$_2$ stems from damages
after 2100. Therefore, we developed a method of extrapolating the
response functions to 2200 using time-series analysis techniques. This
makes tractable the extrapolation problem in the absence of being able
to run the ice sheet models themselves. We treat the dynamic
contribution to SLR estimated by each ice sheet model over the period
1900 to 2100 as a time series. This is first detrended to achieve
stationarity and then the properties of the series are estimated using a
moving average function of the first or second order, or an ARMA
function of the first or second order, with the model being chosen based
on best fit under the Akaike Information Criterion.

[]{#sec:SAF label="sec:SAF"}

Changes in global ice and snow cover also affect the surface albedo
feedback (SAF), increasing net radiative forcing. While these effects
are implicitly captured in the equilibrium climate sensitivity (ECS)
parameter in simple climate models, i.e., the steady-state increase in
temperature in response to a doubling of the atmospheric CO$_{2}$
concentration, doing so assumes that the marginal forcing from an
increase in temperature is constant across temperatures. However, as the
area of ice and snow diminishes, the marginal response for further
increases in temperature decreases. This SAF dynamic has been modelled
by [@yumashev2019climate] using PAGE-ICE and we replicate their model
here.

[@yumashev2019climate] use a quadratic fit of the SAF observed across
the CMIP5 models, shown in the top panel of Figure
[3](#fig:saf){reference-type="ref" reference="fig:saf"}. This falling
SAF curve describes the weakening feedback loop between changes in
temperature and changes in albedo. For low levels of warming, the SAF is
greater than the constant value represented in the ECS; as sea-ice and
land snow diminish, the feedback effect drops. When sea ice and land
snow are absent, the SAF effect is zero. The total radiative forcing due
to albedo, however, always increases with temperature, and reaches its
maximum when sea ice and land snow are absent.

![Variation in surface albedo feedback (SAF) effects as a function of
GMST. **Top:** SAF as a function of temperature, in terms of marginal
increases in forcing per degree Kelvin. **Middle:** adjusted value of
the ECS when SAF forcing is removed. **Bottom:** cumulative forcing from
the SAF, as a function of temperature, in
$W m^{-2}$.](Figures/saf.pdf){#fig:saf width="\\textwidth"}

Total SAF forcing is the integral of the SAF feedback effect across the
change in temperature, reaching 2.67 W m^−2^ at warming of
10$^{\circ}$C. The ECS follows a non-linear curve calculated as a
function of the ECS in the last period, and accounting for the different
level of feedback compared to a constant level. As a consequence, adding
the SAF to the base climate model can result in lower warming
eventually.

The calculations for the SAF correction are shown below. The principle
of the SAF model is to correct temperatures calculated under the process
used in PAGE-ICE, so we first reproduce this temperature calculation.
Global PAGE-ICE atmospheric temperature is calculated as
$$\begin{aligned}
    \Delta\overline{T_{ATM-PAGE1}}(t) =\,& \Delta\overline{T_{ATM-PAGE1}}(t-1)\\
    &+ \left(A(t-1) - \text{FRT} B(t-1) - \Delta\overline{T_{ATM-PAGE1}}(t-1)\right) \left(1 - e^{-1 / \text{FRT}}\right)\\
    &+ B(t-1)\end{aligned}$$ where $$\begin{aligned}
    A(t-1) &= \frac{\text{ECS}}{F_{sl} \ln 2} F(t-1) \\
    B(t-1) &= \frac{\text{ECS}}{F_{sl} \ln 2} (F(t-1) - F(t-2)) \\
    F(t) & \text{\hspace{.5em} is the anthropogenic forcing in our model} \\
    F_{sl} & \text{\hspace{.5em} is the forcing slope, 5.5 W/m2} \\
    \text{FRT} & \text{\hspace{.5em} is the warming half-life, from a triangular distribution from 10 to 55 with mode of 20}\end{aligned}$$

The surface albedo feedback is then calculated using a quadratic
approximation, where SAF decreases more rapidly as temperature
increases. The equations are described as an integral over this
quadratic:
$$\text{SAF}(t) = \frac{C(\Delta\overline{T_{ATM-PAGE1}}(t)) - \text{FSAF}_0}{\Delta\overline{T_{ATM-PAGE1}}(t)-\Delta\overline{T_{ATM-PAGE1}}(2010)}$$
where $$\begin{aligned}
C(\Delta T) &= \beta_2 \Delta T^3/3 + \beta_1 \Delta T^2/2 + \beta_0 \Delta T + \gamma \Delta T \delta \\
\beta_2 & \text{\hspace{.5em} is the $T^2$ coefficient for the SAF quadratic (W/m$^2$/K$^3$)} \\
\beta_1 & \text{\hspace{.5em} is the $T^1$ coefficient for the SAF quadratic (W/m$^2$/K$^2$)} \\
\beta_0 & \text{\hspace{.5em} is the $T^0$ coefficient for the SAF quadratic (W/m$^2$/K)} \\
\gamma & \text{\hspace{.5em} is the standard deviation of the SAF quadratic (W/m$^2$/K)} \\
\delta & \text{\hspace{.5em} is the nonlinearity of SAF, drawn from a symmetric triangular distribution from -1 to 1} \\
\text{FSAF}_0 & \text{\hspace{.5em} is the base year SAF forcing (W/m$^2$)}\end{aligned}$$

The adjustment to the SAF forcing is given by a two-segment correction
$$\begin{aligned}
    \Delta\text{FSAF}(t) =& -\text{SAF}(t) \Delta\overline{T_{ATM-PAGE2}}(t-1)\\
    &+ \begin{cases}
        C(\Delta\overline{T_{ATM-PAGE2}}(t-1)) & \text{if $\Delta\overline{T_{ATM-PAGE2}}(t-1) < 10$} \\
        D(\Delta\overline{T_{ATM-PAGE2}}(t-1))& \text{if $\Delta\overline{T_{ATM-PAGE2}}(t-1) \ge 10$}
    \end{cases}\end{aligned}$$ where $$\begin{aligned}
    D(\Delta T) &= \psi + \alpha (\Delta T-10) + \sigma (\Delta T - 10) \delta \\
    \Delta\overline{T_{ATM-PAGE2}}(t) & \text{\hspace{.5em} is defined below.} \\
    \psi & \text{\hspace{.5em} is the integration constant for SAF forcing at the segment switch point}\\
    \alpha & \text{\hspace{.5em} is the linear SAF segment mean} \\
    \sigma & \text{\hspace{.5em} is the linear SAF segment standard deviation} \\\end{aligned}$$

Also using $SAF(t)$, the adjusted ECS and FRT values are calculated as
$$\begin{aligned}
\text{ECS}' &= \text{ECS}\left(1 - \frac{\text{ECS} \left(\text{SAF}(t) - \overline{SAF}\right)}{F_{sl} \ln 2}\right)^{-1} \\
\text{FRT}' &= \text{FRT}\left(1 - \frac{\text{ECS} \left(\text{SAF}(t) - \overline{SAF}\right)}{F_{sl} \ln 2}\right)^{-1}\end{aligned}$$
where $\overline{SAF}$ is the constant approximation to the SAF (0.34959
W/m$^2$/C).

Then $\Delta\overline{T_{ATM-PAGE2}}(t)$, the adjusted temperature
time-series, is calculated identically to
$\Delta\overline{T_{ATM-PAGE1}}(t)$, but using $\text{ECS}'$,
$\text{FRT}'$, and with the additional forcing $\Delta\text{FSAF}(t)$.
The temperature adjustment produced by the SAF model,
$\Delta\overline{T_{ATM-PAGE2}}(t) - \Delta\overline{T_{ATM-PAGE1}}(t)$,
is then added to the main temperature in the model.

[]{#sec:AMOC label="sec:AMOC"}

Weakening of the Atlantic Meridional Overturning Circulation (AMOC) or
thermohaline circulation,[^9] whether partial or full, has inspired a
number of numerical modelling studies in climate economics
[@anthoff2016shutting; @bahn2011energy; @belaia2017global; @ceronsky2011checking; @keller2004uncertain; @lempert2006multiple; @link2004possible; @link2011estimation; @schlesinger2006assessing].
The majority of these take a stylised approach. Of those aiming for
realism, we choose to incorporate the results of [@anthoff2016shutting]
in our model, because of their unique focus on the effects of AMOC
slowdown at the national level. This is arguably central to the economic
evaluation of AMOC slowdown, because its physical effects would vary
significantly across the world, from a reduction in regional temperature
of several degrees, all else being equal, to an increase in regional
temperature of a few tenths of a degree [see @anthoff2016shutting fig.
1]. The basic logic is that the ocean circulation redistributes heat,
rather than creating or destroying it, and countries vary in their
exposure to this heat redistribution, as well as the effects of global
warming more broadly, depending on their physical location. AMOC
slowdown is expected to have physical effects other than temperature
change, for instance effects on precipitation and regional sea levels
[@lenton2013integrating], but these have yet to be incorporated in
economic studies.

[@anthoff2016shutting] implement four what-if scenarios known in the
context of AMOC slowdown as 'hosing experiments'. In these experiments,
a large exogenous pulse of freshwater is added to the representation of
the North Atlantic in General Circulation Models -- hence the term
hosing -- and the consequences for the AMOC are simulated. Note this is
additional to any gradual slowdown of AMOC captured by the climate
models of CMIP6, which our calibrated pattern scaling of global into
national temperatures already captures (see below). The four scenarios
result in an AMOC slowdown of 7%, 24%, 27% and 67% respectively. This
slowdown is assumed to be reached in the year 2085, after being phased
in linearly from a 2050 starting point. As is by now familiar, we
convert these what-if scenarios into hazard events and assign them
probabilities. The national temperature delta arising from AMOC slowdown
is hence given by $$\begin{aligned}
\Delta T_{\textrm{AT\_AMOC}}(i,t) & = & \Delta T_{\textrm{AT\_AMOC}}(i,t-1)+\left(\dfrac{ \overline{\Delta T_{\textrm{AT\_AMOC}}(i)}}{\Delta_{\textrm{AMOC}}}\right)I_{\textrm{AMOC}}(t)\nonumber \\
 &  & \iff\sum_{s=0}^{t-1}\Delta T_{\textrm{AT\_AMOC}}(i,s)<\overline{\Delta T_{\textrm{AT\_AMOC}}(i)},\label{eq:DeltaT_AT_AMOCbelowthresh}\\
\Delta T_{\textrm{AT\_AMOC}}(i,t) & = & \overline{\Delta T_{\textrm{AT\_AMOC}}(i)}\nonumber \\
 &  & \Longleftrightarrow\sum_{s=0}^{t-1}\Delta T_{\textrm{AT\_AMOC}}(i,s)= \overline{\Delta T_{\textrm{AT\_AMOC}}(i)},\label{eq:DeltaT_AT_AMOCatthresh}\end{aligned}$$
where $\overline{\Delta T_{\textrm{AT\_AMOC}}(i)}$ is the permanent
difference in national annual average temperature as a result of AMOC
slowdown in country $i$. The data points corresponding to
$\overline{\Delta T_{\textrm{AT\_AMOC}}(i)}$ were kindly provided by
Anthoff and colleagues for all countries they covered.
$\Delta_{\textrm{AMOC}}$ is the time taken for AMOC slowdown to phase
in, i.e. 35 years. $I_{\textrm{AMOC}}(t)$ is the indicator function,
whose transition probability from zero to one is

$$\begin{aligned}
p_{\textrm{AMOC}}(t) & = & \begin{cases}
1-\exp\left[-b_{\textrm{AMOC}}\Delta \overline{T_{\textrm{AT}}}(t)\right] \quad \textrm{if } t=1\\
(1-\exp\left[-b_{\textrm{AMOC}}\Delta \overline{T_{\textrm{AT}}}(t)\right])-(1-\exp\left[-b_{\textrm{AMOC}}\Delta \overline{T_{\textrm{AT}}}(t-1)\right]) \quad \textrm{if } t>1
\end{cases},\label{eq:p_AMOC}\end{aligned}$$ conditional on
$I_{\textrm{AMOC}}(t-1)=0$.

To calibrate the hazard rate for each of the four scenarios in
[@anthoff2016shutting], we compile likelihoods as a function of global
mean temperature increase for distinct AMOC shutdown events ranging from
a weakening of 11% to a full shutdown. We obtain these from the IPCC
*Fifth Assessment Report* [@IPCCAR5WG1], its *Special Report on Global
Warming of 1.5$^{\circ}$C* [@IPCCSR1.5CH3], and
[@gosling_likelihood_2013]. Given the limited measurements of AMOC
intensity, these numbers reflect a combination of model-based estimates
and expert judgement. We proceed in two steps: (i) we take the convex
combination of the AMOC shutdown events from the literature that most
closely resembles the what-if scenario at hand. To obtain a hazard rate
$b_{\textrm{AMOC}}$, we then (ii) calibrate Equation
([\[eq:p_AMOC\]](#eq:p_AMOC){reference-type="ref"
reference="eq:p_AMOC"}) by minimizing the sum of squared differences to
the likelihoods obtained in step (i). We estimate
$b_{\textrm{AMOC}}=1.6$ for a 7% slowdown, 0.611 for a 24% slowdown,
0.54 for 27% and 0.135 for 67%.

[]{#sec:ISM label="sec:ISM"}

The first integrated assessment of the Indian Summer Monsoon (ISM) and
its response to climate change has recently been carried out by
[@belaia2017integrated]. This is based on coupling a version of
Nordhaus' regionally disaggregated RICE IAM [@ikefuji2014effect] to a
model of the ISM [@schewe2012statistically]. The ISM is driven by
greater heating of the land surface relative to the ocean in summer,
which creates a pressure gradient that drives moist ocean air over the
Indian subcontinent, where it rises and condenses. However, ISM rainfall
displays important year-to-year variation and the ISM has the potential
to abruptly change regime from wet to dry and *vice versa*. Schewe and
Levermann's model generates these dynamics by incorporating reduced-form
representations of two competing feedback processes. The first is the
so-called moisture advection feedback, a positive feedback whereby
monsoon rains release latent heat, which strengthens the monsoon
circulation and brings more rainfall in turn. The second is the
dry-subsidence effect, a negative feedback whereby high pressure reduces
rainfall, the decreased rainfall leads to less latent heat being
released, which in turn sustains the dry phase. High pressure also
deflects winds away from the monsoon region. In
[@belaia2017integrated]'s model , rainfall depends on both climate
change, through multiple channels, and regional emissions of sulphur
dioxide, which reflect incoming solar radiation, reduce heating over the
Indian subcontinent and weaken the ISM.

The key output of the ISM model that feeds into damages to India (see
below) is average rainfall over the Indian subcontinent over the summer
monsoon season:
$$\overline{P}(t)=\frac{1}{136}\sum_{d=1}^{136}P(d,t),\label{eq:monsoonprecip}$$
where $P(d,t)$ is rainfall on day $d$ of year $t$ and there are 136 days
in each monsoon season.[^10] Each day is either wet or dry, depending on
$$\begin{aligned}
P(d,t) & = & \begin{cases}
P_{\textrm{wet}}(t), & Pr(d,t)<p(d,t),\\
P_{\textrm{dry}} & Pr(d,t)\geq p(d,t),
\end{cases}\end{aligned}$$ where $Pr(d,t)=U(0,1)$, capturing random
variation in day-to-day weather. There is no rainfall on a dry day,
whereas rainfall on a wet day is an increasing function of atmospheric
temperature, since a warmer atmosphere can hold more water:
$$P_{\textrm{wet}}(t)=p^{\prime\prime}\left[\Delta \overline{T_{\textrm{AT}}}(t)-\Delta \overline{T_{\textrm{AT}}}(0)\right]+P_{\textrm{wet}}(0).$$
The initial value of $P_{\textrm{wet}}$ is 9mm per day and it increases
by 0.42mm/day/$^{\circ}$C of global warming.

The probability of a wet day during the first $\delta$ days of the
season -- the onset -- is $$\begin{aligned}
p_{\textrm{init}}(t) & = & \begin{cases}
p_{\textrm{init,1}}(t), & A_{\textrm{pl}}(t)<A_{\textrm{pl,crit}}(t),\\
1-p_{\textrm{m}}, & A_{\textrm{pl}}(t)\geq A_{\textrm{pl,crit}}(t),
\end{cases}\label{eq:p_init}\end{aligned}$$ where $p_{\textrm{m}}=0.82$
is the maximum probability of a wet day.[^11] The formulation in
Eq. ([\[eq:p_init\]](#eq:p_init){reference-type="ref"
reference="eq:p_init"}) makes rainfall during the onset of the season a
function of albedo $A_{\textrm{pl}}(t)$, in particular its relation to a
critical albedo value $A_{\textrm{pl,crit}}(t)$. If the actual albedo
exceeds the critical value, the probability of a wet day is at its
minimum. The critical albedo value is increasing in the atmospheric
concentration of CO$_{2}$,
$$A_{\textrm{pl,crit}}(t)=\alpha_{\textrm{pl,1}}\ln\left[\sum_{i=0}^{3}S_{i}(t)+\underline{S}\right]+\alpha_{\textrm{pl,2}}.$$
$\sum_{i=0}^{3}S_{i}(t)+\underline{S}$ gives the atmospheric CO$_{2}$
concentration and its derivation is explained in the following section.
The actual albedo is given by
$$A_{\textrm{pl}}(t)=A_{\textrm{pl}}(0)+2T_{\textrm{pl}}^{2}(1-A_{\textrm{s}})^{2}\beta_{\textrm{pl}}\alpha_{\textrm{pl,3}}B_{\textrm{SO4}}(t),$$
where $T_{\textrm{pl}}$ is the fraction of light transmitted by the
aerosol layer, $A_{\textrm{s}}$ is the present value of the surface
albedo, $\beta_{\textrm{pl}}$ and $\alpha_{\textrm{pl,3}}$ are
coefficients representing the backscatter fraction and mass scattering
efficiency respectively and $B_{\textrm{SO4}}(t)$ is the regional
sulphate burden over the Indian peninsula. This last quantity depends on
SO$_{2}$ emissions in the region:
$$B_{\textrm{SO4}}(t)=\textrm{SO}_{2}(t)H_{\textrm{SO2}}V/\Omega.$$
Emissions of SO$_{2}$ are exogenous and sourced from the Representative
Concentration Pathway (RCP) database [@moss2010next]. The emissions
scenarios we use are discussed in greater detail below. The RCP database
only disaggregates SO$_{2}$ emissions to the level of the Asian
continent/region, so we downscale to the Indian level by assuming a
constant ratio of Indian/Asian emissions, estimated based on 2010 data
[@li2017india]. The parameter $H_{\textrm{SO2}}$ is the fractional
sulphate yield, $V$ is the atmospheric lifetime of sulphate and $\Omega$
is the land area. Thus the dependence of rainfall on albedo in the model
ultimately captures the local cooling effect of SO$_{2}$ emissions in
the region, which weakens the ISM.

Assuming the actual planetary albedo does not exceed the critical value,
the probability of a wet day during the first $\delta$ days of the
season is
$$p_{\textrm{init,1}}(t)=p^{\prime}\left[m_{\textrm{NINO3.4}}(t)-m_{\textrm{0}}\right]+p_{\textrm{0}},$$
where $m_{\textrm{NINO3.4}}$ is the strength of the Walker circulation,
i.e., the Pacific Ocean atmospheric circulation, in May. The subscript
NINO indicates that the strength of this circulation depends on whether
there is an El Niño or not. El Niño suppresses the ISM. The parameters
$p^{\prime}$, $m_{\textrm{0}}$ and $p_{\textrm{0}}$ are used to
calibrate the response of $p_{\textrm{init,1}}(t)$ to
$m_{\textrm{NINO3.4}}$. The strength of the Walker circulation in May is
in turn given by
$$m_{\textrm{NINO3.4}}(t)=m^{\prime}\left[\Delta \overline{T_{\textrm{AT}}}(t)-\Delta \overline{T_{\textrm{AT}}}(0)\right]+m_{\textrm{NINO3.4}}(0).$$
The probability of a wet day after the first $\delta$ days of the season
is
$$p(d,t)=\dfrac{1/\delta\sum_{i=d-\delta}^{d-1}P(i,t)-P_{\textrm{dry}}}{P_{\textrm{wet}}(t)-P_{\textrm{dry}}},\label{eq:p(d,t)}$$
where $\delta=16$ days.[^12] The probability of a wet day depends
positively on how wet the previous $\delta$ days were, a representation
of the moisture advection and dry-subsidence feedbacks.

[]{#sec:TPinteractions label="sec:TPinteractions"}

Tipping points can interact with each other in multiple ways
[@cai2016risk; @kriegler2009imprecise]. Some of these interactions are
hardwired into the structure of our model. For example, the PCF
increases GMST, which affects all seven remaining tipping points in our
study, because all of them depend on temperature. However, the structure
of our model can only capture a limited subset of all the possible
interactions between tipping points. To increase the number of
interactions, we use the expert elicitation study of
[@kriegler2009imprecise], which attempted to quantify how the triggering
of one tipping point can cause the hazard rates of other tipping points
to change, with a focus on mechanisms other than temperature.

We apply a hierarchical Bayesian analysis to obtain best estimates of
the hazard rate changes provided by the experts in
[@kriegler2009imprecise]. The hazard rate changes -- the interactions --
are represented by a range for expert $i$ from lower bound $u_i$ to
upper bound $n_i$. Each change/interaction is a multiplier on the base
hazard rate, so a value of 1 means no change. We posit a true,
expert-specific hazard rate change, $\theta_i$, and further assume that
these true values are drawn from a normal distribution with unknown mean
and variance. This allows the expert opinions to be partially pooled to
inform the hyperparameters of the normal distribution: $$\begin{aligned}
    \theta_i &\sim \mathcal{N}(\mu, \tau) \\
    \theta_i &\sim \mathcal{U}(u_i, n_i)\end{aligned}$$ We treat cases
where experts were uncertain about the lower bound of the hazard rate
change as having a lower bound of 0, and cases where they were uncertain
about the upper bound as an upper bound of 10. Figure
[4](#fig:hazard-changes){reference-type="ref"
reference="fig:hazard-changes"} presents the results.

![The posterior distribution of $\mu$, the mean of the
hyperdistribution, for each interaction. The error bars in each plot
show the 95% credible interval on $\mu$ for the given interaction. The
light grey lines show each expert's upper and lower bounds (dots are
used if the upper bound equals the lower bound). Abbreviations are as
follows: Atlantic Meridional Overturning Circulation (AMOC), melt of the
Greenland Ice Sheet (GIS), disintegration of the West Antarctic Ice
Sheet (WAIS), and dieback of the Amazon rainforest (AMAZ).
](Figures/hazard-changes.pdf){#fig:hazard-changes width="\\textwidth"}

The set of tipping point interactions included in our study is the union
of the set of interactions hardwired in our model and the set of
interactions quantified by [@kriegler2009imprecise]. To aid
understanding of how many interactions are thereby included, as well as
the direction of each interaction, Table
[3](#tab:TPinteractions){reference-type="ref"
reference="tab:TPinteractions"} provides a matrix.

::: {#tab:TPinteractions}
         PCF       OMH       SAF       AMAZ    GIS      AIS      AMOC       ISM
  ------ --------- --------- --------- ------- -------- -------- ---------- -----------
  PCF              \+        \+        \+      \+       \+       \+         +/-
  OMH    \+                  \+        \+      \+       \+       \+         +/-
  SAF    +/-       +/-                 +/-     +/-      +/-      +/-        +/-
  AMAZ   \+        \+        \+                \+ (0)   \+ (0)   \+ (+/-)   +/- (+/-)
  GIS    no int.   no int.   no int.   (+/-)            (+)      (+)        \(0\)
  AIS    no int.   no int.   no int.   \(0\)   (+/-)             (+/-)      \(0\)
  AMOC   no int.   no int.   no int.   (+/-)   (-)      (+/-)               \(0\)
  ISM    no int.   no int.   no int.   (+)     \(0\)    \(0\)    (+/-)      

  : Interactions between tipping points included in this study. Each
  cell indicates the qualitative effect of the row tipping point on the
  column tipping point. Where the row tipping point can increase or
  decrease the intensity/likelihood of the column tipping point,
  depending on time or state, we write +/-. Parentheses indicate the
  interaction is calibrated on the expert elicitation study by
  [@kriegler2009imprecise]. The absence of parenthesis indicates the
  interaction is hardwired in the model structure. Zeros indicate an
  interaction that is included, but that has a statistical zero effect
  according to [@kriegler2009imprecise]. No int. means the interaction
  is not included at all. n.b. ISM affects other tipping points via
  ENSO, implicit in the expert estimates of the relevant hazard rate
  changes. AIS interactions are calibrated on the ice sheet responses of
  the four Western regions of Antarctica only, to match with the notion
  of WAIS in [@kriegler_imprecise_2009].
:::

[]{#sec:climatemodule label="sec:climatemodule"} []{#sec:emissions
label="sec:emissions"} The principal inputs to the climate model are
global emissions of CO$_{2}$ and CH$_{4}$. Other anthropogenic and
natural sources of radiative forcing, both positive and negative, are
aggregated into an exogenous residual radiative forcing series.[^13]
Anthropogenic emissions come from the scenarios described in the
scenario section above. The second source of emissions is the
carbon-cycle feedbacks described in the previous section, i.e.,
permafrost melting, dissociation of ocean methane hydrates, and Amazon
rainforest dieback.

[]{#sec:CO2andCH4cycles label="sec:CO2andCH4cycles"}

CO$_2$ and CH$_4$ emissions are mapped into atmospheric concentrations
using the FaIR simple climate model, version 2.0.0 [@leachFaIRv2],
specifically the Julia-Mimi implementation of the model available at
https://github.com/FrankErrickson/MimiFAIRv2.jl.git. This updates the
CO$_2$ and CH$_4$ cycles from META-2021, which were based on FaIRv1.0
[@millar2017modified] for CO$_2$ and our own representation of the
CH$_4$ cycle.

In FaIR, each gas cycle is represented by the following system of
equations (sticking with discrete time notation and following closely
the Julia-Mimi implementation): $$\begin{aligned}
C(t) & = & \underline{C}+\frac{1}{2}\left[\sum_{i=1}^{n}R_{i}(t-1)+\sum_{i=1}^{n}R_{i}(t)\right],\\
R_{i}(t) & = & E(t)\frac{a_{i}}{\delta_{i}(t)}\left[1-e^{-\delta_{i}(t)}\right]+R_{i}(t-1)e^{-\delta_{i}(t)},\\
\delta_{i}(t) & = & \frac{1}{\alpha(t)\tau_{i}},\\
\alpha(t) & = & g_{0}\exp\left(\frac{r_{0}+r_{u}G_{u}(t-1)+r_{T}\Delta\overline{T_{AT}}(t-1)+r_{a}G_{a}(t-1)}{g_{1}}\right),\end{aligned}$$
where $$\begin{aligned}
G_{a}(t) & = & \sum_{i=1}^{n}R_{i}(t),\\
G_{u}(t) & = & \sum_{s=t_{0}}^{t}E(s)-G_{a}(t),\end{aligned}$$ and
$$\begin{aligned}
g_{1} & = & \sum_{i=1}^{n}a_{i}\tau_{i}\left[1-\left(1+100/\tau_{i}\right)e^{-100/\tau_{i}}\right],\\
g_{0} & = & \exp\left(-\frac{\sum_{i=1}^{n}a_{i}\tau_{i}\left[1-e^{-100/\tau_{i}}\right]}{g_{1}}\right).\end{aligned}$$

$C(t)$ is the atmospheric stock/concentration of a given GHG, which is
the sum of the pre-industrial stock $\underline{C}$ and the stock above
pre-industrial. This stock above pre-industrial comprises $i=n$
boxes/reservoirs $R_{i}$ (four for CO$_{2}$ and one for CH$_{4}$).
Emissions $E$ of the GHG in question are apportioned to box $i$
according to its uptake fraction $a_{i}$ and are removed at rate
$\delta_{i}$, which itself is a function of the decay timescale of the
box $\tau_{i}$ and a state-dependent adjustment $\alpha$, which links
the removal rate of the GHG from the atmosphere to current cumulative
uptake $G_{u}$, warming $\Delta\overline{T_{AT}}$, and the stock above
pre-industrial $G_{a}$. This state-dependent adjustment is a signature
of the FaIR model and is capable of simulating positive and negative
feedbacks in the gas cycle. $r_{0}$ is the strength of pre-industrial
uptake from the atmosphere. The constants $g_{0}$ and $g_{1}$ are used
for calibration of the state-dependent adjustment.

[]{#sec:forcingandtemp label="sec:forcingandtemp"}

We also use FaIRv2.0.0 to convert atmospheric concentrations into
effective radiative forcing and temperature change. This is also an
update on META-2021, which used FaIRv1.0 [@millar2017modified] for
CO$_2$ and [@Myhre2013] for CH$_4$. In general, the FaIR forcing
equation includes logarithmic, square-root and linear terms:
$$F(t)=\sum_{x}^{\textrm{forcing agents}}\left\{ f_{1}^{x}\ln\left[\frac{C^{x}(t)}{\underline{C^{x}}}\right]+f_{2}^{x}\left[C^{x}(t)-\underline{C^{x}}\right]+f_{3}^{x}\left[\sqrt{C^{x}(t)}-\sqrt{\underline{C^{x}}}\right]\right\} +F_{\mathrm{ext}}.$$
In META, the number of forcing agents $x=2$, namely CO$_2$ and CH$_4$;
$F_{\mathrm{ext}}$ is the sum of forcings from all other agents. For
CO$_2$, the forcing relationship comprises the logarithmic and
square-root terms only; for CH$_4$, just the square-root term
[@leachFaIRv2].

From forcing, the increase in GMST is governed by a model comprising
three heat boxes, which is one more than FaIRv1: $$\begin{aligned}
\Delta\overline{T_{AT}}(t) & = & \frac{1}{2}\left[\sum_{j=1}^{3}\Delta\overline{T_{j}}(t)+\sum_{j=1}^{3}\Delta\overline{T_{j}}(t-1)\right],\\
\Delta\overline{T_{j}}(t) & = & \Delta\overline{T_{j}}(t-1)e^{-1/d_{j}}+F(t)q_{j}\left(1-e^{-1/d_{j}}\right),\end{aligned}$$
where $\Delta\overline{T_{j}}$ is the temperature change for box $j$,
$e^{-1/d_{j}}$ is the thermal response decay factor, where $d_{j}$
represents the thermal response timescale, and $q_{j}$ is a radiative
forcing coefficient.

[]{#sec:economicmodule label="sec:economicmodule"}

[]{#sec:SLR label="sec:SLR"}

Sea level rise comprises a contribution from thermal expansion and melt
from glaciers and small ice caps, $SLR_{\textrm{THERM}}(t)$, as well as
a contribution from disintegration of the GIS and AIS:
$$\sum SLR(t)=SLR_{\textrm{THERM}}(t)+SLR_{\textrm{GIS}}(t)+SLR_{\textrm{AIS}}(t).\label{eq:Sigma_SLR}$$
Sea level rise is defined relative to the year 2000 and
$\sum SLR(0)=0.04$m [@church2011sea]. To model the contribution from
thermal expansion and melt from glaciers and small ice caps, we follow
[@diaz2016potential] in specifying SLR as a linear function of warming:
$$SLR_{\textrm{THERM}}(t)=\left(r_{\textrm{TE}}+r_{\textrm{GSIC}}\right)\Delta \overline{T_{\textrm{AT}}}(t)+SLR_{\textrm{THERM}}(t-1),\label{eq:SLR_THERM}$$
where $r_{\textrm{TE}}=0.00078$ and $r_{\textrm{GSIC}}=0.00081$
parameterise the rates of SLR from thermal expansion and melt from
glaciers and small ice caps respectively. Sea level rise from thermal
expansion is parameterised such that 1$^{\circ}$C warming results in a
very long-term equilibrium increase of 0.5m (i.e., over the course of
approximately 1000 years).

[]{#sec:temp label="sec:temp"}

We convert the increase in GMST relative to pre-industrial into the
increase in national mean surface temperature using statistical
downscaling. This procedure has been updated from META-2021 and now uses
data from CMIP6. We subsequently add the effect of AMOC slowdown.

For country $i$, the change in mean surface temperature relative to
pre-industrial is estimated using the following relationship:
$$\Delta T_{\textrm{AT}}(i,t)=\alpha(i)+\beta(i)\Delta \overline{T_{\textrm{AT}}}(t)+\Delta T_{\textrm{AT\_AMOC}}(i,t).\label{eq:downscaling}$$
The coefficients $\alpha$ and $\beta$ are estimated by regressing
national mean surface temperature change from the CMIP6 dataset on
corresponding GMST change. National mean surface temperature is
constructed from the gridded CMIP6 output using population weights. We
pool all available CMIP6 models and, for each model, we pool temperature
changes from the historical runs with future projections on RCP2.6,
RCP4.5, RCP7.0 and RCP8.5. We also tested quadratic and cubic
specifications of the national-global temperature change relationship,
but the linear model was preferred based on the AIC and BIC; the
relationship appears to be highly linear for all countries.

[]{#sec:damagesandincome label="sec:damagesandincome"}

Income growth depends on exogenous drivers, as well as damages from
changing temperatures and SLR (and from the summer monsoon in India,
only). Post-damage income per capita in country $i$, $y(i,t)$, grows
according to
$$y(i,t)=\overline{y}(i,t-1)\left[1+g_{\textrm{EX}}(i,t)+D_{\textrm{TEMP}}(i,t)\right]\left[1-D_{\textrm{SLR}}(i,t)\right],$$
where $g_{\textrm{EX}}(i,t)$ is an exogenous, country- and time-specific
growth rate that is taken from the SSP database [@oneill2014new].[^14]
The SSP scenarios are only defined until 2100. To extend these scenarios
until 2300, we follow a procedure described in Section
[\[apx:sspextend\]](#apx:sspextend){reference-type="ref"
reference="apx:sspextend"}.

$D_{\textrm{TEMP}}(i,t)$ are temperature damages, which are given by
$$D_{\textrm{TEMP}}(i,t)=\beta_{1}\left[T_{\textrm{AT}}(i,t)-T_{\textrm{AT}}(i,0)\right]+\beta_{2}\left[T_{\textrm{AT}}(i,t)-T_{\textrm{AT}}(i,0)\right]^{2},\label{eq:temp_damages}$$
where the coefficients $\beta_{1}$ and $\beta_{2}$ are taken from the
econometric analysis of [@burke2015global].

$D_{\textrm{SLR}}(i,t)$ are SLR damages, which are given by
$$D_{\textrm{SLR}}(i,t)=\theta(i)\sum SLR(t),\label{eq:SLR_damages}$$
where $\theta(i)$ parameterises the cost to country $i$ per unit SLR. We
obtain SLR damages from Diaz's CIAM model [@diaz2016estimating]. We run
CIAM to obtain estimates of national coastal damage/adaptation costs as
a function of SLR in two scenarios, (i) no adaptation and (ii) optimal
adaptation. We treat each country's adaptation decisions as uncertain
and obtain a symmetrical triangular distribution for each $\theta(i)$
with a minimum corresponding to costs in (i) and a maximum corresponding
to costs in (ii). We use costs/SLR in 2050 for the calibration, a simple
approach facilitated by the fact that the relationship between the two
is approximately linear over the 21st century [@diaz2016estimating].

In India, there is an additional damage multiplier
$D_{\textrm{ISM}}(IND,t)$, so that national income per capita is given
by $$\begin{aligned}
y(IND,t) & = & \overline{y}(IND,t-1)\left[1+g_{\textrm{EX}}(IND,t)+D_{\textrm{TEMP}}(IND,t)\right]\times\ \nonumber\\
& & \times\left[1-D_{\textrm{SLR}}(IND,t)\right]\left[1-D_{\textrm{ISM}}(IND,t)\right].\label{eq:income_growth}\end{aligned}$$
Following [@belaia2017integrated], the ISM damage multiplier is given by
$$\begin{aligned}
D_{\mathrm{ISM}}(t) & = & \begin{cases}
D_{\mathrm{drought}}, & \overline{P}(t)\leq\overline{P}_{\mathrm{drought}},\\
0, & \overline{P}_{\mathrm{drought}}<\overline{P}(t)<\overline{P}_{\mathrm{flood}},\\
D_{\mathrm{flood}}, & \overline{P}(t)\geq\overline{P}_{\mathrm{flood}}.
\end{cases}\end{aligned}$$ This structure implies that only extremely
wet monsoon seasons and extremely dry monsoon seasons affect income in
India, with the measure of precipitation being average rainfall for the
monsoon season $\overline{P}(t)$. The drought threshold
$\overline{P}_{\mathrm{drought}}=2.8667$mm/day, while the equivalent
flood threshold $\overline{P}_{\mathrm{flood}}=7.6667$mm/day.
Drought-related damages $D_{\mathrm{drought}}=3.5\%$ of GDP, while
flood-related damages $D_{\mathrm{flood}}=0.85\%$. All these parameter
values are taken from [@belaia2017integrated].

The level of income per capita in the previous year, on which damages in
the current year work, is given by
$$\overline{y}(i,t-1)=\varphi y_{\textrm{EX}}(i,t-1)+\left(1-\varphi\right)y(i,t-1),\label{eq:damage_weighting}$$
where $y_{\textrm{EX}}(i,t-1)$ is counterfactual income per capita, also
taken from the SSP database, $y(i,t-1)$ is the *actual* post-damage
income per capita experienced, and $\varphi$ parameterises the weight
given to each. This specification enables us to explore two different
interpretations of the empirical evidence on temperature damages, as
well as convex combinations of them. The first interpretation is that
temperatures impact the level of income in each year, in effect driving
a wedge between what output is feasible given implicit factors of
production and productivity, and what output is actually achieved. This
has been the traditional approach in climate economics, e.g., in
Nordhaus' DICE model. The production possibilities frontier is assumed
to evolve exogenously. Such 'levels' damages correspond with
$\varphi=1$. The second interpretation is that temperatures impact the
growth rate of income by directly impacting the accumulation of factors
of production and/or by impacting productivity growth [@Dietz2015]. Such
'growth' damages correspond with $\varphi=0$. The persistence of damages
and the extent to which they impact growth/levels is an active area of
debate in climate economics
[@newell2021gdp; @casey2023projecting; @klenow2023much]. We calibrate
$\varphi$ on the long-run projections of [@klenow2023much], which
suggest that warming on the RCP8.5 scenario would reduce global GDP by
11.5% by 2100. Given estimates of temperature, SLR and ISM damages, this
implies $\varphi=0.25$.

[]{#sec:utilitywelfareSCCO2 label="sec:utilitywelfareSCCO2"}

Post-damage national income per capita is first converted into
consumption per capita using a country-specific but time-invariant
savings rate,
$$c(i,t)=\left[1-s(i)\right]y(i,t),\label{eq:consumption}$$ where the
country savings rates $s(i)$ are calibrated on observed national savings
rates averaged over the period 2005-2015, using World Bank data. Savings
data are missing for many countries, in which case we impute the global
average, also obtained from the World Bank. This specification assumes
savings are exogenous and do not respond to changing income prospects.
Fully endogenous savings are computationally infeasible in a model with
this much complexity and detail. The limitations of assuming
constant/exogenous savings have been discussed in the literature, e.g.,
[@golosov2014optimal]. Small to moderate climate damages do not appear
to shift savings rates measurably.

Consumption is converted into utility using a standard,
constant-elasticity-of-substitution representation,
$$u(i,t)=\dfrac{c(i,t)^{1-\eta}}{1-\eta},\label{eq:utility}$$ where
$\eta$ is the elasticity of marginal utility of consumption.

To compute overall welfare, we specify a discounted classical/total
utilitarian social welfare functional. We begin by calculating welfare
for each country $i$:
$$W(i)=\sum_{t=2020}^{T}\left(1+\rho\right)^{-t}u(i,t)L(i,t),\label{eq:welfare}$$
where $\rho$ is the utility discount rate, a.k.a. the pure rate of time
preference. Discounted, population-adjusted current period utility is
then summed over the whole modelling horizon to obtain total welfare.
Population data are exogenous and taken from the SSP scenarios.

Global welfare follows naturally as the sum of welfare across all
countries $i$: $$W=\sum_{i}W(i)\label{eq:globalwelfare}$$

[]{#sec:nonmarketdamages label="sec:nonmarketdamages"}

The above damages from temperature, SLR and the ISM can be regarded as
'market' damages. Market damages are those climate damages affecting
economic activity mediated by money. Market damages do not include
estimates of the welfare cost of climate change outside markets, for
example loss of human life [@mcduffie2023scch4] or damages to ecosystems
that can be priced at people's willingness to pay (WTP) to preserve
those ecosystems' existence. 'Non-market' damages are more uncertain
than their market counterparts, but in many IAMs they occupy a
substantial share of total welfare damages from climate change [e.g.
@nordhaus2000warning; @Rennert2022].

We use the non-market damage module of the MERGE IAM [@manne2005merge],
with an updated calibration derived from @howard2017few. The MERGE model
places particular emphasis on the representation of non-market damages,
with a WTP measure that depends on both income and temperature. While
the parameters of the MERGE non-market damage module are speculative,
its use of an S-shaped elasticity of WTP with respect to income is
theoretically coherent.

Like the MERGE model, the damage function meta-analysis by
@howard2017few assumes that damages grow quadratically with warming from
a pre-industrial baseline. Under their preferred model, total damages as
a percent of GDP (including market and non-market impacts) follow
$\num{0.595} \Delta \overline{T_{AT}}(t)^2$. Considering only damage
functions that exclude non-market damages, their key coefficient is
reduced by 0.487.[^15] We use this as evidence that non-market damages
follow $\num{0.487} \Delta \overline{T_{AT}}(t)^2$. As in
@howard2017few, we increase this coefficient by 25%, to $\num{0.609}$,
to account for potential omitted (non-catastrophic) damages. This gives
a 90% increase in WTP relative to @manne2005merge. At 2.5$^{\circ}$C
warming, WTP is 3.8% of GDP, compared to 2.0% in the original MERGE
calibration (see Figure [5](#fig:merge-dmgfunc){reference-type="ref"
reference="fig:merge-dmgfunc"}).

![Willingness to pay to avoid levels of warming, split by levels of
income. The original and updated calibrations are
shown.](Figures/merge-dmgfunc.pdf){#fig:merge-dmgfunc
width="\\textwidth"}

This WTP applies at high incomes. MERGE provides a model to link WTP to
income, which we maintain. At \$25k/capita, WTP to avoid 2.5$^{\circ}$C
warming is held at 1%. As income increases above that level, WTP
asymptotically approaches the non-market damages from @howard2017few.
WTP to avoid warming as a function of income is shown in Figure
[6](#fig:merge-scurve){reference-type="ref"
reference="fig:merge-scurve"}.

![Willingness to pay to avoid 1.5, 2.5, and 4 $^{\circ}$C, as a function
of income, under the original and updated
calibrations.](Figures/merge-scurve.pdf){#fig:merge-scurve
width="\\textwidth"}

We calculate this WTP measure at a national level. The non-market damage
multiplier, or economic loss function, is
$$D_{\text{NM}}(i,t) = \left[1 - \left(\left(\frac{\Delta \overline{T_{\textrm{AT}}}(t)}{\Delta T_{\text{cat}}}\right)^2 - \left(\frac{\Delta \overline{T_{\textrm{AT}}}(0)}{\Delta T_{\text{cat}}}\right)^2\right)\right]^{h(i,t)}.$$
where $\overline{T_{\textrm{AT}}}(0)$ is the temperature in the baseline
period, which is taken to be 2010.

This is a hockey-stick function embodying the assumption that non-market
damages can increase rapidly as temperatures become more extreme.
$\Delta T_{\text{cat}}$ is a catastrophic warming parameter set to
12.82$^{\circ}$C, which people are assumed to be willing to avoid at any
cost[^16]. $h(i,t)$ is the hockey-stick parameter, which depends on
country income per capita ($y(i, t)$):
$$h(i,t) = \min{\left[\frac{\log{\left[1 - \frac{D_{\text{ref}}}{1+100\exp{[-WTP_{\text{ref}} y(i,t)]}}\right]}}{\log{\left[1 - \left(\nicefrac{\Delta T_{\text{ref}}}{\Delta T_{\text{cat}}}\right)^2\right]}}, 1\right]},$$
where $$\begin{aligned}
WTP_{\text{ref}} & = 0.143 & \text{WTP 1\% of GDP to avoid reference warming at \$25k/capita} \\
D_{\text{ref}} & = 0.038 & \text{WTP loss at reference warming} \\
\Delta T_{\text{ref}} & = \SI{2.5}{C} & \text{WTP reference warming}\end{aligned}$$

The non-market damage multiplier is applied to country-level utility:
$$u(i,t) = u\left(D_{\text{NM}}(i,t)c(i,t)\right)$$ for utility function
$u(\cdot)$ as specified above.

[]{#sec:marginaldamages label="sec:marginaldamages"}

The marginal damage cost/social cost of carbon or methane along a
particular scenario of emissions, income and population is the
difference in welfare caused by a marginal emission of the gas,
normalised by the marginal welfare value of a unit of consumption in the
base year:
$$\textrm{SCC}(t)=\dfrac{\partial W/\partial E(t)}{\partial W/\partial c(t)}.
\label{eq:SCC}$$ To calculate the numerator, we run the model twice with
identical assumptions, the second time with an additional pulse of
emissions. Let $\vartheta_{m}$ represent a vector of parameter values
from the model, representing in abstract form the many parameters
described above. These are in most cases random draws from a
distribution, including individual tipping event realisations. Then we
calculate
$$\left[\frac{\partial W}{\partial E(t)}\right]_m = \frac{W[E(t) + \Delta_{E}(t), \vartheta_m] - W[E(t), \vartheta_m]}{\Delta_{E}(t)},
\label{eq:dwde}$$ where $\Delta_{E}$ is the emissions pulse. We focus on
an emissions pulse in 2020.

The denominator of [\[eq:SCC\]](#eq:SCC){reference-type="eqref"
reference="eq:SCC"}, $\partial W/\partial c(t)$, depends on the
consumption level of the normalising agent. We define this as the global
average individual, i.e., global mean consumption per capita:
$$\bar{c}(t,\theta_m) = \frac{\sum_i c(i,t,\vartheta_m)L(i,t)}{\sum_i L(i,t)}.$$
Note that this is also uncertain and depends on the vector of random
parameters. Differentiating the utility function, we then have
$$\left[\frac{\partial W}{\partial c(t)}\right]_m = \bar{c}(i,t,\theta_m)^{-\eta}.
\label{eq:dwdc}$$ We focus on a base year of 2020. We then calculate the
negative of the ratio of Equations
[\[eq:dwde\]](#eq:dwde){reference-type="eqref" reference="eq:dwde"} and
[\[eq:dwdc\]](#eq:dwdc){reference-type="eqref" reference="eq:dwdc"} for
each draw of random parameters $m$ and take expectations over all draws.
The numeraire in the model is year 2010 US dollars, corresponding to the
year in which GDP is initialised. We inflate our reported SCC values to
year 2020 US dollars using a factor of 1.2, based on data from
[@WorldBank2020].[^17]

[]{#apx:sspextend label="apx:sspextend"}

To estimate post-2100 income and population along the SSP scenarios, we
fit a model to the available pre-2100 SSP scenario data and use the
fitted model to extrapolate. The same model is applied to both income
and population and is defined in terms of growth rates. The model
postulates that changes in pre-2100 income and population growth rates
are explained by a rate of convergence and a rate of decay.

The model is as follows: $$\label{eq:SSP_growth}
    \text{Growth}(i,t) = (1 - \beta - \delta) \text{Growth}(i,t-1) + \delta \text{MeanGrowth}(t-1),$$
where $\delta$ is the rate of convergence, $\beta$ is the decay rate and
$$\text{MeanGrowth}(t-1) = \sum_i \frac{\text{Population}(i, 2015)}{\sum_j \text{Population}(j, 2015)} \text{Growth}(i,t-1).$$
Below, we write this as $\text{Growth}(\cdot,t-1) \cdot w$, where $w$ is
the vector of global population shares for each country.

SSP data are not available in every year, so fitting
Eq. [\[eq:SSP_growth\]](#eq:SSP_growth){reference-type="eqref"
reference="eq:SSP_growth"} requires a model with dynamics. We use a
two-step approach, fitting the model using Stan, a computational Bayes
system. The first step uses the available data directly, fitting
$$\text{Growth}(i,s) \sim \mathcal{N}\left( [1 - \Delta t (\beta + \delta)] \text{Growth}(i,s-1) + \Delta t \delta \text{MeanGrowth}(s-1), \sigma_i\right),$$
where $s$ is a time step, $\Delta t$ is the number of years between time
steps, and country $i$ has uncertainty $\sigma_i$. We apply a prior that
both $\beta$ and $\delta$ are between 0 and 0.5.

Next, we fit the full model, using the results of the simplified model
to improve the Bayesian model convergence. In this case, for a given
Markov chain Monte Carlo draw of $\beta$ and $\delta$, we calculate the
entire time series:
$$\widehat{\text{Growth}}(i,t) \sim \mathcal{N}\left((1 - \beta - \delta) \widehat{\text{Growth}}(i,t-1) + \delta \left[\widehat{\text{Growth}}(\cdot,t-1) \cdot w_\cdot\right], \sigma_i\right)$$
starting with $\widehat{\text{Growth}}(i, 2015)$ as reported in the SSP
dataset.

The probability evaluation is over both the performance of the fit and
the priors: $$\begin{aligned}
\text{Growth}(i,s) &\sim \mathcal{N}\left(\widehat{\text{Growth}}(i,t(s)), \sigma_i\right) \\
\beta &\sim \mathcal{N}\left(\mu_\beta, \sigma_\beta\right) \\
\delta &\sim \mathcal{N}\left(\mu_\delta, \sigma_\delta\right) \\
\log{\sigma_i} &\sim \mathcal{N}\left(\mu_{\sigma,i}, \sigma_{\sigma,i}\right)\end{aligned}$$
where $\mu$ is the mean estimate of the corresponding parameter and
$\sigma$ is the standard deviation across its uncertainty. The prior for
$\sigma_i$ is defined as a log-normal, centered on the mean of the
estimates of log $\sigma_i$. The estimates for each SSP are shown in
Table [4](#tab:SSPs_after_2100){reference-type="ref"
reference="tab:SSPs_after_2100"}.

::: {#tab:SSPs_after_2100}
   SSP      Variable       $\delta$       $\beta$
  ----- ---------------- ------------- -------------
    1    GDP per capita   0.006205028   0.005930520
    1      Population     0.008967453   0.005215835
    2    GDP per capita   0.004190444   0.007228942
    2      Population     0.001276993   0.011064426
    3    GDP per capita   0.006273030   0.009597363
    3      Population     0.001064697   0.007688331
    4    GDP per capita   0.006895296   0.009651277
    4      Population     0.001867587   0.003461600
    5    GDP per capita   0.007766807   0.003843256
    5      Population     0.003470952   0.004305310

  : Estimated convergence and decay rates for extrapolation of growth of
  GDP per capita and population in the SSP socio-economic scenarios
  beyond 2100
:::

[^1]: They also injected a smaller pulse of 25GtCH$_{4}$ between 2015
    and 2025 in one scenario.

[^2]: There is further uncertainty about whether the CH$_{4}$ that
    reaches the ocean bottom eventually escapes into the atmosphere (it
    depends on aerobic oxidation of CH$_{4}$ by bacteria in the water
    column), however this uncertainty is thought to be smaller.

[^3]: Indeed, the scenarios in [@whiteman2013climate] were criticised at
    the time of publication for being unrealistic in the context of
    Arctic subsea processes; see *Nature* volume 300, p529.

[^4]: Based on digitising Figure 7 in their paper.

[^5]: The resulting model is called DICE-GIS and builds on DICE-2016R2.

[^6]: [@nordhaus2019economics] also reports runs in which
    $T_{\textrm{GIS}}^{\ast}(t)=T_{\textrm{GIS\_MAX}}\left[1-V_{\textrm{GIS}}(t)\right]^{0.5}$
    and finds the results are very similar.

[^7]: Noting that the melt rate coefficient $\beta_{GIS}$ below also
    needs to be recalibrated to -0.0000088 to fit
    [@robinson2012multistability].

[^8]: This corresponds with Nordhaus' [@nordhaus2019economics] reported
    value per five years divided by 5 to bring it into line with our
    annual time step, then divided by 100 given that we define
    $V_{\textrm{GIS}}(t)$ as a fraction.

[^9]: We use these two terms interchangeably.

[^10]: For computational reasons, we use a four-day time step, so
    $P(d,t)$ changes at most once every four days and there are 136 days
    in the season, compared with 135 in [@belaia2017integrated].

[^11]: By bounding the probability of a wet day during the onset of the
    monsoon season, the system does not become irrevocably locked into
    either a wet or dry state.

[^12]: With a four-day time step, we set the memory period $\delta=16$
    days, rather than 17 days as in [@belaia2017integrated].

[^13]: This is the sum of forcing from: (i) N$_{2}$O; (ii) flourinated
    gases controlled under the Kyoto Protocol; (iii) ozone-depleting
    substances controlled under the Montreal Protocol; (iv) total direct
    aerosol forcing; (v) the cloud albedo effect; (vi) stratospheric and
    tropospheric ozone forcing; (vii) stratospheric water vapour from
    methane oxidisation; (viii) land-use albedo; (ix) black carbon on
    snow.

[^14]: https://tntcat.iiasa.ac.at/SspDb

[^15]: This coefficient comes from table 2, column 3 of @howard2017few.
    While their preferred model is column 4, that model has a
    market-only reduction of 0.622, larger than the total damage
    coefficient. Columns 3 and 4 estimate identical values for the total
    damage coefficient, so we use the more conservative value.

[^16]: The catastrophic warming temperature is derived from the
    assumption that economic losses rise quadratically according to the
    @howard2017few calibration.

[^17]: The inflation factor is 1.2 whether one uses the Consumer Price
    Index or the GDP deflator.
