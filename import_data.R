##### List of libraries required #####
library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(caret)
library(xgboost)
library(reshape2)

##### Importing datasets ######
# Function to read multiple excel worksheets
multiple_sheets <- function(filename){
  data <- filename %>%
    excel_sheets() %>%
    set_names() %>%
    map(read_excel, path = filename)
}

# Setting file path
path <- "./data/2023-student-research-compiled.xlsx"

# Importing all data  
data_full <- multiple_sheets(path)

# Hazard data 
hazard <- data_full$`Hazard Data`
for(n in 1:nrow(hazard)){
  # Cleaning hazard data
  if(hazard$`Hazard Event`[n] == "Severe Storm/Thunder Storm - Wind"){
    hazard$`Hazard Event`[n] <- "Severe Storm/Thunder Storm/ Wind"
  }
}

# Demographic Economic data
demo_eco <- data_full$`Demographic-Economic`
# Cleaning demographic economic data
colnames(demo_eco)[1] <- 'Data'
demo_eco[] <- lapply(demo_eco, gsub, pattern = "Ꝕ", replacement = "")
demo_eco[-c(1)] <- lapply(demo_eco[-c(1)], gsub, pattern = ",", replacement = "")
demo_eco[-c(1)] <- lapply(demo_eco[-c(1)], gsub, pattern = " ", replacement = "")
demo_eco[-c(1)] <- lapply(demo_eco[-c(1)], as.numeric)

# Inflation data
infl_int <- data_full$`Inflation-Interest`