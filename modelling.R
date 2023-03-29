# Importing code
source("eda.R")

##### Data Severity Modelling Preparation #####
# Setting a priority list to map/categorise Hazard Events
# This priority list was based off the mean of solo/duo hazards
hazard_priority <- c("Hurricane", "Wildfire",
                     "Tornado", "Flooding", "Winter Weather",
                     "Lightning", "Severe Storm",
                     "Wind", "Coastal", "Drought",
                     "Hail", "Heat")

# For loop to map hazard events based off priority list
for(i in hazard_priority){
  for(k in 1:nrow(hazard)){
    if(grepl(i, hazard$`Hazard Event`[k]) == TRUE){
      hazard$`Hazard Event`[k] <- i
    }
  }
}

# For loop to now categorise left over hazard events as 'Other'
for(k in 1:nrow(hazard)){
  if(sum(grepl(hazard$`Hazard Event`[k], hazard_priority)) == 0){
    hazard$`Hazard Event`[k] <- "Other"
  }
}

# Creating a new dataframe to prepare the data modelling
hazard_sev <- hazard
hazard_sev[,c(1,2,3)] <- sapply(hazard_sev[, c(1,2,3)], as.character)

# Changing 0's to 1 due to gamma distribution
hazard_sev$`Property Damage`[which(hazard_sev$`Property Damage` == 0)] <- 1

# One hot encoding the factor variables
dummy <- dummyVars(" ~ .", data = hazard_sev)
hazard_sev <- data.frame(predict(dummy, newdata = hazard_sev))

# Creating datasplit
set.seed(1)
parts <- unlist(createDataPartition(1:nrow(hazard_sev), p = 0.8))

# Train severity data
train_severity <- hazard_sev[parts,]
# Test severity data
test_severity <- hazard_sev[-parts,]

# Formatting training data so that it can be used in xgboost
dtrain_sev <- xgb.DMatrix(data = data.matrix(train_severity[,-c(28)]), 
                          label = data.matrix(train_severity[,c(28)]))

# Splitting testing set into its inputs and output
test_input_sev <- data.matrix(test_severity[,-c(28)])
test_labels_sev <- data.matrix(test_severity[,c(28)])

# Setting method for tuning using 5 fold cross validation
train_control <- trainControl(method = "cv", number = 5, search = "random")

# Tuning the parameters for xgboosted regression
set.seed(1)
severity_tune <- caret::train(X.Property.Damage.~.,
                              data = train_severity,
                              method = "xgbTree",
                              objective = "reg:gamma",
                              trControl = train_control,
                              tuneLength = 10)
severity_tune

# Training the model with optimised parameters 
severity_model <- xgb.train(data = dtrain_sev,
                            objective = "reg:gamma",
                            nrounds = severity_tune$bestTune$nrounds,
                            params = c(severity_tune$bestTune[-1]))

# Checking RMSE
pred_sev <- predict(severity_model, test_input_sev)
RMSE(pred_sev, test_labels_sev)

# Checking RSQ
tss_sev <- sum((test_labels_sev - mean(test_labels_sev))^2)
rss_sev <- sum((pred_sev - test_labels_sev)^2)
rsq_sev <- 1 - rss_sev/tss_sev
rsq_sev

# Checking importance of variables
importance_matrix <- xgb.importance(names(test_input_sev), model = severity_model)
xgb.plot.importance(importance_matrix,
                    xlab = "Relative Importance of severity variables")

##### Data Preparation for Frequency #####
# Expanding rows such that there is a combination for all Region, Hazard Event, Quarter and Year
hazard_all <- hazard %>%
  expand(Region, `Hazard Event`, Quarter, Year)
hazard_freq <- hazard %>% dplyr::right_join(hazard_all)
hazard_freq$`Property Damage`[!is.na(hazard_freq$`Property Damage`)] <- 1
hazard_freq$`Property Damage`[is.na(hazard_freq$`Property Damage`)] <- 0
hazard_freq <- hazard_freq %>%
  group_by(Region, `Hazard Event`, Quarter, Year) %>%
  summarise(Freq = sum(`Property Damage`))

# One hot encoding the categorical data
hazard_freq[,c(1,2,3)] <- sapply(hazard_freq[, c(1,2,3)], as.character)
dummy <- dummyVars(" ~ .", data = hazard_freq)
hazard_freq <- data.frame(predict(dummy, newdata = hazard_freq))

# Splitting data randomly 
set.seed(1)
parts2 <- unlist(createDataPartition(1:nrow(hazard_freq), p = 0.8))

# Train data
train_freq <- hazard_freq[parts2,]
# Test data
test_freq <- hazard_freq[-parts2,]

# Formatting data so it can be used in xgboost
dtrain_freq <- xgb.DMatrix(data = data.matrix(train_freq[,-c(25)]),
                           label = data.matrix(train_freq[,c(25)]))

# Splitting testing data into inputs and output
test_input_freq <- data.matrix(test_freq[,-c(25)])
test_labels_freq <- data.matrix(test_freq[,c(25)])

##### Modelling XGBoost for Frequency #####
# Tuning the parameters for xgboosted regression
set.seed(1)
freq_tune <- caret::train(Freq~.,
                          data = train_freq,
                          method = "xgbTree",
                          objective = "reg:tweedie",
                          trControl = train_control,
                          tuneLength = 10)
freq_tune

# Training data with optimised parameters
freq_model <- xgb.train(data = dtrain_freq,
                        objective = "reg:tweedie",
                        nrounds = freq_tune$bestTune$nrounds,
                        params = c(freq_tune$bestTune[-1]))

# Predict the test data using the trained model and checking RMSE
pred_freq <- predict(freq_model, test_input_freq)
RMSE(pred_freq, test_labels_freq)

# Checking RSQ
tss_freq <- sum((test_labels_freq - mean(test_labels_freq))^2)
rss_freq <- sum((pred_freq - test_labels_freq)^2)
rsq_freq <- 1 - rss_freq/tss_freq
rsq_freq

# Looking at the importance of each variable
importance_matrix_freq <- xgb.importance(names(test_input_freq), model = freq_model)
xgb.plot.importance(importance_matrix_freq,
                    xlab = "Relative Importance of frequency variables")
