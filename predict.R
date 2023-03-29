# Import code
source("modelling.R")

##### Estimating minor, medium and major hazards for 2020 and getting confidence intervals #####
# Creating a new data frame containing all possible expansions of hazards, region, quarter for 2020
hazard_2020_all <- hazard %>%
  expand(Region, `Hazard Event`, Quarter)
hazard_2020_all$Year <- 2020

# Data frame to summarise each hazard event's Duration, Fatalities and Injuries
hazard_summ_new <- hazard %>%
  group_by(Region, `Hazard Event`) %>%
  summarise(Duration = mean(Duration),
            Fatalities = mean(Fatalities),
            Injuries = mean(Injuries))

# Joining Duration, Injury and Fatality data to the data frame and replacing NA's with 0
hazard_2020_sev <- hazard_summ_new %>% dplyr::right_join(hazard_2020_all, multiple = "all")
hazard_2020_sev[is.na(hazard_2020_sev)] <- 0

# One hot encoding the factor variables for severity dataframe
hazard_2020_sev[,c(1,2,6)] <- sapply(hazard_2020_sev[, c(1,2,6)], as.character)
dummy <- dummyVars(" ~ .", data = hazard_2020_sev)
hazard_2020_sev <- data.frame(predict(dummy, newdata = hazard_2020_sev))
hazard_2020_sev <- hazard_2020_sev %>% relocate(c(Duration, Fatalities, Injuries), .after = Year)

# Removing columns Duration, Fatalities and Injuries to create frequency dataframe
hazard_2020_freq <- hazard_2020_sev[,-c(25,26,27)]

# Bootstrapping samples from training data to create models
set.seed(1)
freq_resample <- createResample(1:nrow(train_freq), times = 100)
sev_resample <- createResample(1:nrow(train_severity), times = 100)

# Empty dataframes for bootstrapped predictions of property damages, and hazard frequency
minor_damage_df <- 
  medium_damage_df <-
  major_damage_df <- 
  minor_damage_df <- 
  minor_freq_df <- 
  medium_freq_df <- 
  major_freq_df <- 
  minor_sev_df <- 
  medium_sev_df <- 
  major_sev_df <- data.frame(matrix(nrow = 0, ncol = 6))

# Function to extract data from data frame given a lower and upper bound
separate_haz <- function(df, lower = -Inf, upper = Inf){
  sep_haz <- (df > lower & df <= upper) * df
  sep_haz[sep_haz == 0] <- NA
  avg <- sapply(sep_haz, mean, na.rm = TRUE)
  return(avg)
}

# For loop to model bootstrapped data and store results onto its corresponding dataframe
for(i in 1:length(freq_resample)){
  # Empty dataframe
  freq_df <- data.frame(temp = 1:(nrow(hazard_2020_freq)/6))
  # Training models with bootstrapping to predict 2020 frequency
  train_freq_i <- train_freq[unlist(freq_resample[i]),]
  dtrain_freq_i <- xgb.DMatrix(data = data.matrix(train_freq_i[,-c(25)]),
                               label = data.matrix(train_freq_i[,c(25)]))
  freq_model_i <- xgb.train(data = dtrain_freq_i,
                            objective = "reg:tweedie",
                            nrounds = freq_tune$bestTune$nrounds,
                            params = c(freq_tune$bestTune[-1]))
  # Predicting hazard frequency for 2020
  freq_pred_i <- predict(freq_model_i, data.matrix(hazard_2020_freq))
  # Storing data onto dataframe
  for(k in 1:length(unique(hazard$Region))){
    region <- freq_pred_i[hazard_2020_freq[,k] == 1]
    freq_df[paste("Region", k, sep = "")] <- region
  }
  freq_df <- freq_df[, -1]
  
  # Training models using bootstrapped samples to predict 2020 severity
  sev_df <- data.frame(temp = 1:(nrow(hazard_2020_sev)/6))
  train_severity_i <- train_severity[unlist(sev_resample[i]),]
  dtrain_sev_i <- xgb.DMatrix(data = data.matrix(train_severity_i[,-c(28)]),
                              label = data.matrix(train_severity_i[,c(28)]))
  severity_model_i <- xgb.train(data = dtrain_sev_i,
                                objective = "reg:gamma",
                                nrounds = severity_tune$bestTune$nrounds,
                                params = c(severity_tune$bestTune[-1]))
  # Predicting hazard severity for 2020
  sev_predict_i <- predict(severity_model_i, data.matrix(hazard_2020_sev))
  # Storing data onto severity dataframe
  for (k in 1:length(unique(hazard$Region))){
    region <- sev_predict_i[hazard_2020_sev[,k] == 1]
    sev_df[paste("Region", k, sep = "")] <- region
  }
  sev_df <- sev_df[, -1]
  # Calculating expected hazard frequency
  minor_freq <- colSums(freq_df * (sev_df <= 500000))
  medium_freq <- colSums(freq_df * (sev_df > 500000 & sev_df <= 5000000))
  major_freq <- colSums(freq_df * (sev_df > 5000000))
  minor_freq_df <- rbind(minor_freq_df, minor_freq)
  medium_freq_df <- rbind(medium_freq_df, medium_freq)
  major_freq_df <- rbind(major_freq_df, major_freq)
  # Calculating average property damage per event
  minor_sev <- separate_haz(sev_df, upper = 500000)
  medium_sev <- separate_haz(sev_df, lower = 500000, upper = 5000000)
  major_sev <- separate_haz(sev_df, lower = 5000000)
  minor_sev_df <- rbind(minor_sev_df, minor_sev)
  medium_sev_df <- rbind(medium_sev_df, medium_sev)
  major_sev_df <- rbind(major_sev_df, major_sev)
  # Calculating expected property damages per event category
  minor_damage <- colSums((sev_df * (sev_df <= 500000)) * freq_df)
  medium_damage <- colSums((sev_df * (sev_df > 500000 & sev_df <= 5000000)) * freq_df)
  major_damage <- colSums((sev_df * (sev_df > 5000000)) * freq_df)
  minor_damage_df <- rbind(minor_damage_df, minor_damage)
  medium_damage_df <- rbind(medium_damage_df, medium_damage)
  major_damage_df <- rbind(major_damage_df, major_damage)
}
# Naming dataframe columns 
colnames(minor_damage_df) <-
  colnames(medium_damage_df) <- 
  colnames(major_damage_df) <- 
  colnames(minor_freq_df) <- 
  colnames(medium_freq_df) <-
  colnames(major_freq_df) <- 
  colnames(minor_sev_df) <- 
  colnames(medium_sev_df) <-
  colnames(major_sev_df) <- colnames(hazard_sev[,1:6])

# Function to create a dataframe containing confidence intervals and mean
conf_int <- function(df, conf_lv = 0.95){
  lower <- sapply(df, mean, na.rm = TRUE) - qnorm(1/2 + conf_lv/2) * sqrt(sapply(df, var, na.rm = TRUE))/sqrt(nrow(df))
  upper <- sapply(df, mean, na.rm = TRUE) + qnorm(1/2 + conf_lv/2) * sqrt(sapply(df, var, na.rm = TRUE))/sqrt(nrow(df))
  average <- sapply(df, mean, na.rm = TRUE)
  conf_int_df <- data.frame(lower, upper, average)
  return(conf_int_df)
}
# Obtaining confidence intervals and mean for expected damages and hazard frequency
conf_int(minor_damage_df + medium_damage_df + major_damage_df)
conf_int(minor_damage_df)
conf_int(medium_damage_df)
conf_int(major_damage_df)
conf_int(minor_freq_df)
conf_int(medium_freq_df)
conf_int(major_freq_df)
conf_int(minor_sev_df)
conf_int(medium_sev_df)
conf_int(major_sev_df)

# Function to plot the distribution of the bootstrapped predicted results
plot_box <- function(df, title = NULL, xlab = "Region", ylab = NULL){
  ggplot(data = melt(df), aes(x = variable, y = value)) +
    geom_boxplot(aes(fill = variable)) +
    stat_summary(fun = mean, geom = "point", colour = "red", shape = 16, size = 2.5) +
    ggtitle(title) +
    ylab(ylab) +
    theme_minimal()
}

# Plotting predicted bootstrapped models onto a boxplot
plot_box(minor_damage_df, title = "Expected Minor Hazard Damages", ylab = "$")
plot_box(medium_damage_df, title = "Expected Medium Hazard Damages", ylab = "$")
plot_box(major_damage_df, title = "Expected Major Hazard Damages", ylab = "$")
plot_box(minor_damage_df + medium_damage_df + major_damage_df, title = "Total Expected Damages", ylab = "Damages")
plot_box(minor_freq_df, title = "Minor Hazard Frequency", ylab = "Frequency")
plot_box(medium_freq_df, title = "Medium Hazard Frequency", ylab = "Frequency")
plot_box(major_freq_df, title = "Major Hazard Frequency", ylab = "Frequency")
plot_box(minor_sev_df, title = "Minor Hazard Severity", ylab = "$")
plot_box(medium_sev_df, title = "Medium Hazard Severity", ylab = "$")
plot_box(major_sev_df, title = "Major Hazard Severity", ylab = "$")

# Parameters for optimised model
freq_tune
severity_tune

# Rsq values
rsq_freq
rsq_sev
