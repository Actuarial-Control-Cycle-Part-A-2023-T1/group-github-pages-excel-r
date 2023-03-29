# Importing data
source("import_data.R")

##### Exploratory Data Analysis #####
# Hazard Event Summary
hazard_summ <- hazard %>% 
  group_by(`Hazard Event`) %>%
  summarise(freq = n(),
            mean_duration = mean(Duration),
            mean_fatalities = mean(Fatalities),
            mean_injuries = mean(Injuries),
            mean_damage = mean(`Property Damage`),
            median_damage = median(`Property Damage`))

# Summarized Data using Region and Quarter
region_summary <- hazard %>%
  group_by(Region, Quarter) %>% 
  summarise(freq = n(),
            mean_duration = mean(Duration),
            mean_fatalities = mean(Fatalities),
            mean_injuries = mean(Injuries),
            mean_damage = mean(`Property Damage`))

# Function to visualize data from dataframe 'region_summary'
region_plot <- function(xvar, yvar, title = NULL){
  region_summary$Region <- as.character(region_summary$Region)
  ggplot(data = region_summary, aes({{xvar}}, {{yvar}})) +
    geom_line(aes(color = Region), linewidth = 1) +
    ggtitle(title)
}

# Visualising the data from the dataframe 'region_summary'
region_plot(Quarter, freq, "Number of Hazards")
region_plot(Quarter, mean_duration, "Duration of Hazards")
region_plot(Quarter, mean_fatalities, "Average Fatalities ")
region_plot(Quarter, mean_injuries, "Average Injuries")
region_plot(Quarter, mean_damage, "Mean Property Damage")

# Summarised data into yearly data
region_yearly <- hazard %>%
  group_by(Region, Year) %>%
  summarise(num_hazard = n(),
            mean_duration = mean(Duration),
            mean_fatalities = mean(Fatalities),
            mean_injuries = mean(Injuries),
            mean_damage = mean(`Property Damage`),
            total_damage = sum(`Property Damage`))

# Function to visualise the dataframe 'region_yearly'
region_yearly_plot <- function(yvar, title = NULL){
  region_yearly$Region <- as.character(region_yearly$Region)
  ggplot(data = region_yearly, aes(Year, {{yvar}})) +
    geom_line(aes(color = Region), linewidth = 0.8) +
    ggtitle(title) +
    theme_minimal()
}

# Visualising the dataframe "region_yearly"
region_yearly_plot(num_hazard, "Yearly Hazard Frequency")
region_yearly_plot(mean_duration, "Average Hazard Duration")
region_yearly_plot(mean_fatalities, "Average Fatalities")
region_yearly_plot(mean_injuries, "Average Injuries")
region_yearly_plot(mean_damage, "Average Property Damage")
region_yearly_plot(total_damage, "Total Property Damage")

# Focusing on events that occur without any other events
split_events <- grepl("/", hazard_summ$`Hazard Event`)
ggplot(hazard_summ[!split_events,], aes(x = `Hazard Event`, y = mean_damage)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  ylab("Average Property Damages")
  
