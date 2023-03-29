# Relocation Social Insurance Case Study (Excel > R )@ UNSW

---

## Executive Summary
The increasing frequency and severity of climate-related catastrophes have the potential to cause significant consequences to households, both financially and psychologically. This report seeks to propose a recommendation for a new social insurance program for Storslysia to mitigate such consequences. The key objectives of the social insurance program are first outlined before providing insights on the program design. After an outline of the social insurance program, further analysis on the costing of the program is performed, followed by an examination on key assumptions, risks, and limitations of the analysis. Based on such investigations, we conclude that the introduction of a social insurance program would be beneficial to Storslysia.

## Objectives of Proposed Social Insurance Program

In line with the required targets set by the task force in Storslysia, the proposed social insurance program has two main objectives:
I. To incentivise permanent voluntary relocation for those individuals residing in high and medium risk regions to low-risk regions; and
II. To reduce the economic and psychological costs for households from displacement caused by the increasing environmental disasters in Storslysia
In addition to the above objectives, we further suggest specific key performance indicators (KPIs) to monitor the success of the program. These main KPIs include the number of people who have voluntarily relocated from a high-risk region to a low-risk region, the reduction in financial cost caused by the program and surveys to collect feedback from those who have used the program to relocate voluntarily. By monitoring such KPIs on a yearly basis in the short term, and on a 5 yearly basis in the long term, the program’s success will be continually monitored, and the program will be adjusted accordingly.

## Program Design
 
### Eligibility Criteria

The main target audience of the proposed social insurance program are individuals currently residing in medium and high-risk regions. We have defined medium risk regions as Region 1 and high risk regions as Region 2. Regions 3,4,5 and 6 are classified as low risk regions in our discussion. These classifications have been made after a modelling process of the total expected damages for 2020 in each of these regions. It was found that Region 2 had the highest expected total damage from natural disasters of Ꝕ29,641,524.5, followed by Region 1 with a value of Ꝕ19,489,281.8. The other regions however, had a significantly lower expected total damage, hence being classified as ‘low risk’. Further details regarding the modelling process can be seen in the discussions that follow.

### Main Features of the Program
In the event of an eligible application, the proposed social insurance program provides a benefit payment to the household to help them relocate to a low-risk region which, in addition to covering a proportion of the permanent housing cost, includes a lump sum payment allowing each household to cover for a portion of their healthcare, food services and accommodation, transportation costs as well as any potential pauses in their income stream. Under current modelling processes, our team assumes that coverage for potential pauses in income stream is not covered in the payment given to households in the case of involuntary relocation. Therefore, we predict that the inclusion of such a component in addition to the subsidisation of other costs as well as certain coverage of relocation costs will help incentivise individuals to relocate to a safer region. Further breakdown of each of these components is explained in the pricing discussion below.

### Evaluation Timeline of the Program
We propose the program be evaluated yearly for 5 years, before being evaluated on a 5 yearly basis afterwards. To justify this timeline of program evaluation, several factors such as the timeframe since the launch of the program, target audience and the type of insurance product was considered in our actuarial judgement. Given that the proposed insurance program targets climate risk which identifies as a long-term risk and the target audience is large spanning over 10 million individuals in 2020, assuming that those in low-risk regions do not use the program, we believe a yearly evaluation is appropriate. Once the program eases into the community, and cost projections are on track to an appropriate extent, we then propose the program to be monitored every 5 years whereby the government may make further amendments to the program.

## Pricing and Costing
---
The economic costs are projected over both a short-term and a long-term timeframe. In the short-term, the costs with and without the program are forecasted on an annual basis from 2021 to 2030. Henceforth the costs are projected every decade until 2100.
The economic cost of a climate hazard event is a complex phenomenon that is influenced by several factors, including the severity and duration of the event, the location and extent of the damage, and the economic and social structures in the affected area. The costs can be direct or indirect, and in this study, we investigate the economic costs of climate hazards in terms of:
* property damage,
* displacement and relocation costs,
* healthcare and social assistance costs,
* transportation and warehousing costs, and
*  food service.

To estimate the costs associated with property damage, we use Extreme Gradient Boosting to estimate the damage in different regions:

### Property Damage Forecast with Extreme Gradient Boosting
In the provided dataset, there were many different categories of ‘Hazard Events’ (50 different categories after cleaning the data), with many of them containing multiple climate-related catastrophes. This resulted in many dimensions when modelling and thus, a priority list for climate-related catastrophes was constructed where the ‘Hazard Event’ will take the name of the climate-related catastrophe placed highest on the priority list. See Appendix A for the priority list. This allowed 50 climate event categories to be reduced to 13.
The modelling for expected property damages was split into frequency and severity, both using XGBoost. The Tweedie Distribution was used as the objective function to minimise due to its ability to model count data and account for high number of zeros. The parameters were tuned using a Random Search to optimise for 5-fold cross validation and the R-squared metric was utilised for the testing set. The severity modelling was a similar process, with duration, injuries and fatalities as added variables, and the objective function to be minimised was Gamma Distribution due to its ability to model skewed data containing high severity amounts. The R-squared values obtained from the testing set were 0.42 and 0.52 respectively. See [code](modelling.R) for optimised parameters and importance of variables. 

### Expected Property Damages for 2020

Although the data set has provided the actual property damages for 2020, this does not reflect its ‘expected’ value due to the high variance nature of climate-related catastrophes each year. One-hundred bootstrapped models were trained with the optimised parameters to predict frequency and severity of climate-related catastrophes for 2020. The corresponding set of predictions were then multiplied to obtain 100 predictions, shown in Figure 1 below. A 95% confidence interval was calculated to be used for the construction of the program pricing and costs. See Appendix C (Figure 14) for the average predictions and the 95% confidence interval. Climate-related catastrophes were also split into minor, medium and major severities with breakpoints at Ꝕ500,000 and Ꝕ5,000,000.

<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228497774-851513ea-cfb7-48d1-baf1-4308ca92c1f4.png">
</p>

<h6 align="center"> 
< Figure 1: Boxplot of Total Expected Damages for 2020 >
</h6>



### Calculating Involuntary Relocation (Emergency Displacement) Costs

The overall costs associated with involuntary relocation comprises the following: Expected Property Damages, Involuntary Displacement, Healthcare, Food Service, Transportation and Covering Household Goods.

Expected Property Damages: The upper confidence interval was used for expected property damages, providing us with 97.5% confidence that expected property damages will be below this threshold. The expected property damage in each region is indexed with estimated inflation each year and the risk amplification factor (RAF). As such, the proportion of people affected by hazardous events can be estimated by taking property damage over the total property value in different areas. However, property that has been affected by climate-related catastrophes will have different levels of impairment. As such, we assume that, on average, the percentage impairment of all property is around 5%.

Involuntary Displacement: Given the expected property damages, we can create a distribution of property damages attributed to minor, medium and major hazard severities. As such, we can consider different loadings for different intensities of climate-related catastrophes to account for the increase in material, labour costs and duration associated with displacement. 

For example, a minor hazard is estimated to have on average a 10% price surge on temporary accommodation and affected individuals will be supported for a month on average.

Healthcare, Food Service, Transportation: This was similarly calculated using the same method as Involuntary Displacement. However, the provided data shows healthcare, food service and transportation for 2017. As such, we projected these values to 2020 using the given inflation data. 
Covering Household Goods: Household goods are estimated to be 40 – 75% of property damages. Different hazard severities were given appropriate loadings. For example, minor hazards would require 40% of property damages to cover household goods, medium hazards would require 57.5%, and major hazards would require 75%. Note that inflation has been accounted for all relevant costings.

<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228501019-009f2f70-90a4-4100-9515-c11abdcec632.png">

<h6 align="center"> 
<Figure 2: Involuntary Relocation Costing under no Program represented as a % of Storslysia’s GDP>
</h6>

In Figure 2 shown above, we can see exponential trends for involuntary costing for high emissions scenario (i.e. SSP3 and SSP5) and will most likely exceed 10% of Storslysia’s GDP after 2100. 

----

### With Program Costing

The costs with the program are examined as two components:
1. The cost to incentivise residents in the high and medium-risk regions to relocate to low-risk regions. This cost includes: the reimbursement of a percentage of the permanent housing cost incurred as a result of relocation and a lump sum payment to account for the temporary loss of income, food and transportation expenses that may occur as a result of relocation.
2. The costs associated with involuntary displacement after climate-related disasters. These include the cost of repairing damaged properties and household goods, temporary living arrangements, as well as emergency food, heath care and transportation services.

### Population Forecast with the Program
The cost projection model stems from a population forecast model. Starting with the 2020 census data as the base population, it is predicted that 0.5% of the population from Region 2 (high-risk) and 0.25% from Region 1 (medium-risk) will voluntarily move to the low-risk regions (Regions 3, 4, 5, 6) every year from 2020 to 2030. The above percentages are estimated using various survey data regarding individuals’ willingness to move from disaster- prone areas. Assumptions regarding individuals’ response towards relocation beyond 2030 should be made when further data becomes available. Hence, no migration has been included in the model beyond 2023 in this analysis. The population forecast model incorporates the voluntary movement induced by the program as well as the projected organic population growth as set out in each SSP scenario. The below graph captures a snapshot of how this population forecast model functions:
<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228501891-cbf5fea8-dd8b-49f1-a366-2b4b8eaef6ba.png">
</p>

The number of households in each region in a particular year (say 2020) is derived by dividing the population by the average number of people per household. The average number of people per household is assumed to be stable over time. The number of vacant housing units is estimated by deducting the number housing units by the number of households.
Every year, the number of population outflow from Region 1 and 2 are allocated to low-risk regions according to the proportion of vacant housing units in low-risk regions.
The Census data of the next year will then consider the population inflow and outflow on top of the organic population growth. In the meantime, the total housing units every year are calculated using a constant housing unit growth rate, estimated using the number of building permits in 2021. Applying the same process, the Census data can be forecasted recursively.


### Relocation Incentive Package
The program provides a benefit package to incentivise residents to migrate from high and medium-risk regions. This package will include:
1. A 10% reimbursement of the resident’s permanent housing cost.

*  Total projected cost of this benefit in year i will be:

  $\sum_{region 3, 4, 5, 6}$ h𝑜𝑢𝑠𝑒h𝑜𝑙𝑑𝑠 𝑖𝑛𝑡𝑜 𝑟𝑒𝑔𝑖𝑜𝑛 𝑡 𝑑𝑢𝑟𝑖𝑛𝑔 𝑦𝑒𝑎𝑟 𝑖 × 𝑝𝑟𝑜𝑝𝑒𝑟𝑡𝑦 𝑐𝑜𝑠𝑡 𝑖𝑛 𝑟𝑒𝑔𝑖𝑜𝑛 𝑡 × 10%

*  Where the number of households moving into region t is estimated as the total number of people migrating into region t $/$ average number of people per household in region t.

*  The property cost is estimated as the weighted average property value in region t, indexed by inflation annually.

2. A lump sum that covers 50% of the households’ expenses associated with relocation in the early stage, e.g., transportation, healthcare, food and accommodation costs, as well as participant’s loss of income.

*  The transportation, healthcare, food and accommodation costs per household are calculated via the 2017 data, indexed by inflation annually. See Appendix D for more details regarding the calculation of the value of the lump sum.

* The value of the lump sum is designed to be equal between the four low-risk regions to avoid additional drivers for differential preferences in individuals’ relocation destination.

As such the total cost of the relocation inventive for the program is

 $\sum_{t: region 3, 4, 5, 6}$ (10% 𝑅𝑒𝑖𝑚𝑏𝑢𝑟𝑠𝑒𝑚𝑒𝑛𝑡 𝑜𝑓 𝑃𝑒𝑟𝑚𝑎𝑛𝑒𝑛𝑡 𝐻𝑜𝑢𝑠𝑖𝑛𝑔 𝐶𝑜𝑠𝑡 + 50% 𝑅𝑒𝑙𝑜𝑐𝑎𝑡𝑖𝑜𝑛 𝐴𝑠𝑠𝑜𝑐𝑖𝑎𝑡𝑒𝑑 𝐸𝑥𝑝𝑒𝑛𝑠𝑒𝑠) $\*$ 𝑁𝑢𝑚𝑏𝑒𝑟 𝑜𝑓 𝐻𝑜𝑢𝑠𝑒h𝑜𝑙𝑑𝑠 𝑖𝑛𝑡𝑜 𝑅𝑒𝑔𝑖𝑜𝑛 𝑡

### Involuntary Displacement Costs with the Program

The projection of the involuntary displacement costs with the program utilises the same process and modelling as the involuntary cost projection without the program. The difference in the displacement costs originates from the difference in the Census forecast.

### Impact of the Program

The implementation of the program has resulted in a notable decline in the involuntary costs associated with climate hazards over the years. This reduction is observed across various emission scenarios but is particularly significant in high-emissions cost scenarios such as SSP3 and SSP5 over the long-term. This demonstrates the efficacy of the program in reducing the adverse economic impacts of climate hazards and mitigating their effects in severity scenarios.

<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228504835-537f0570-9e49-42e7-9927-71fab882ca00.png">
</p>

<h6 align="center"> 
<Figure 3: Involuntary cost relative % decrease>
</h6>

To account for potential uncertainties and ensure the program's financial stability, we incorporate a 20% risk margin into our calculations. This additional factor takes into consideration any unforeseen risks that may arise and helps to maintain the program's long- term viability. The total capital required to remain solvent is calculated as the sum of the voluntary cost and the involuntary cost multiplied by the risk margin.
Under the high emission scenario in 2030, the approximate amount of capital to be held to remain solvent is a maximum of 7.448 billion. This is a critical consideration in maintaining the financial sustainability of the program and ensuring that it can continue to provide much- needed support to those affected by climate hazards.
To maintain the program's solvency in the long term, up to 2100, a total capital amount of around 579 billion is predicted to be required. This amount is calculated by taking into account the various cost factors and risk margins associated with the program, and it serves as an important consideration in ensuring its continued effectiveness and sustainability. Overall, even under the worst-case scenario, the capital required to hold in the program is below 0.05% of GDP.

<p align="center">  
<img src="https://user-images.githubusercontent.com/124782714/228505036-ecb08a30-2c06-4a68-adb6-91504f0dbf46.png">
</p>

<h6 align="center"> 
<Figure 4: Capital needed to remain solvent as a % of Storslysia’s GDP>
</h6>

## Assumptions

### Economic Assumptions
A time series analysis on the provided inflation data showed no clear trends, seen below in Figure 5. As such, future levels of inflation were assumed to be a constant, where this constant was calculated by taking the historical average of inflation.

<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228505331-5eaab29a-80dc-4b1c-9e5c-107a29a87cae.png">
</p>

<h6 align="center"> 
<Figure 5: Time Series of Historical Inflation> 
</h6>

### Pricing Assumptions
Other economic data such as Census and GDP for Storslysia were assumed to follow the global scenarios provided by the IPCC and the values were projected based on the same assumptions. Linear interpolation was conducted between the years of 2020 and 2030 to project economic data for the respective years.
Expected Property Damages were similarly projected using the IPCC data on the risk amplification factor (RAF). However, an additional assumption was made that the severity of climate-related catastrophes also followed the RAF. Thus, Expected Property Damages was projected by taking the square of the RAF for the corresponding year.
The program is available for any citizen of Storslysia, however, we assume that only citizens of high risk-regions choose to relocate under risk-averse conjectures.

### Data Assumptions
All given data were assumed to be statistical data from 2020 unless stated otherwise. This included housing units and property value distribution. For data where a time range was given (i.e., Households), we assumed the data reflected the most recent year. Another assumption was that entries with zero property damage still counted as a climate-related catastrophe due to any injuries or fatalities that may have occurred.

## Risk and Risk Mitigation

<p align="center"> 
<img src="https://user-images.githubusercontent.com/124782714/228505642-5ccfdd69-8dfb-4565-9cbc-c3b2a948f367.png">
</p>

<h6 align="center"> 
<Figure 6: Risk Matrix>
</h6>

### Climate Risk - More climate disasters than anticipated

The frequency of climate disasters may be greater than anticipated. Under these circumstances, there is the threat that the program will be too expensive to execute and may be less preferable than involuntary relocation. To consider such factors, we adjusted our program to grow in pace with IPCC risk amplification factors in order for costs to meet budget constraints across all SSP scenarios.

### Implementation Risk - More people than expected use of the program

More people than expected may opt to use the program which could jeopardise its financial feasibility, resulting in a program which is more expensive than current policies in place. This would render the program useless in its goal to provide a cost-effective solution to relocation. To address this, we modelled costs to account for changes in population due to relocation. We performed sensitivity analyses to determine the efficacy of this adjustment by comparing the relative difference in involuntary relocation costs with and without the program (see Figure 7). Our analysis finds that involuntary relocation costs under the program are overall cheaper, regardless of the level of people relocating or SSP scenario.

 <p align="center"> 
 <img src="https://user-images.githubusercontent.com/124782714/228506279-1b4a39d8-db15-4c46-9144-d8da52be6d7c.png">
 </p>

<h6 align="center"> 
<Figure 7: Relocation % Involuntary Difference (SSP5)>
</h6>

### Inflation Rate Risk

There is risk that inflation will be higher or lower than expected, resulting in the total relocation program exceeding budget constraints. If the costs become too high, this could also affect the viability of other expenditure items Storslysia is committed to delivering - weakening the economy and creating political risk for the current government. To address this, we conducted sensitivity analyses to determine the impact of changing inflation rates (see Figure 8). The program exceeds 10% of GDP at high inflation rates in the distant future (2090 and onwards). To mitigate this risk, Storslysia should closely monitor inflation throughout the years and anticipate the need to cover for the shortfall if necessary, such as through raising taxes.

 <p align="center"> 
 <img src="https://user-images.githubusercontent.com/124782714/228506498-7b2b1e45-be7c-44dc-8b24-38950a3d2d1e.png">
 </p>
 <h6 align="center"> 
 <Figure 8: Sensitivity Analysis – Program Cost as % of GDP (SSP5)>
 </h6>

## Data and Data Limitations
### Errors and Inaccuracies

The data supplied contained erroneous and inaccurate entries. For example, the inflation and interest rate data included extreme outliers, missing values and null values. We attempted to correct for these by using averages to fill in erroneous values.

### Supplied Data Limitations
Historical data is crucial to establishing long-term trends. However, given the small sample size of the data, it was difficult for our models to accurately reflect expected long-term trends. For example, temporary housing cost projections could only be estimated based on one year of data. Our GDP projections were projected using two years of data. Therefore, this increased uncertainty in the accuracy of our projections. We attempted to overcome this by tending towards more conservative assumptions in order to ensure constraints were met under unfavourable circumstances and leveraging other information such as projecting GDP with risk amplification factors.
In some cases, the data also lacked specificity and consistency, particularly in the demographic and economic data. Multiple entries did not specify which year they corresponded to such as with temporary housing cost with disaster and number of housing units, resulting in assumptions taken to match these entries temporally with other similar data in the table. The hazard data also reported data points with no property damage which was difficult to properly quantify given our model considered severity in terms of damage (not fatalities or injuries).
The hazard events data also lacked granularity. Several weather events were often clumped together instead of being categorised separately. This made it hard to determine how much each hazard event contributed to the property damage. The data also did not specify how many households were affected, resulting in further assumptions that were made to estimate how many people were affected by weather events.

### Novelty of program
Due to the prototypical nature of the program, there were issues in estimating certain values. There was no historical experience to inform our expectations on how many people may consider voluntary relocation (such as a survey) or any previous experience of such a program occurring in a neighbouring country. This required us to make assumptions based on real-world studies and relocation programs which may not perfectly match each region in its experience of climate disasters or demographic makeup. This results in a potentially wide band of counterfactual possibilities when it comes to several of our assumptions such as how many people are expected to voluntarily relocate.

## Conclusion 
The aim of this program was to reduce emergency displacement-related costs. The increasing frequency and severity of climate-related catastrophes will cause significant consequences to households, both financially and psychologically in the long term. As such, our main initiative was to relocate citizens from higher risk regions, specifically Regions 1 and 2 into lower risk regions. The implementation of the program has resulted in a notable decline in the involuntary costs associated with climate hazards over the years.

![](Actuarial.gif)
