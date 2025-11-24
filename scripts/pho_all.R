library(reshape2)
library(lubridate)
library(dplyr)


# DATA
target_names = c("covid", "flu", "rsv")

download.file("https://raw.githubusercontent.com/ai4castinghub/hospitalization-forecast/refs/heads/main/target-data/season_2025_2026/hospitalization-data.csv", destfile = "target_data.csv")
df_target_data <- read.csv("target_data.csv")
target_columns = names(df_target_data)
region_names = unique(df_target_data$geo_value)
df_target_data = melt(df_target_data, id = c("time", "geo_value", "geo_type"))

download.file("https://raw.githubusercontent.com/ai4castinghub/hospitalization-forecast/refs/heads/main/auxiliary-data/concatenated_hospitalization_data.csv", destfile = "target_data_all.csv")
df_target_data_all <- read.csv("target_data_all.csv")
df_target_data_all = melt(df_target_data_all, id = c("time", "geo_value", "geo_type", "Season"))

df_target_data_all$value[is.na(df_target_data_all$value)] = 0 
df_target_data_all$time <- as_date(df_target_data_all$time)
df_target_data_all <- df_target_data_all[order(df_target_data_all$time),]

df_target_data_all$value[df_target_data_all$value < 1] = 1
df_target_data$value[df_target_data$value < 1] = 1


# FORECAST
horizon_names = c("h-1", "h0", "h1", "h2", "h3")
horizons = c(-1, 0, 1, 2, 3)
reference_date = as_date("2025-11-22") # CURRENTLY USED FORECAST!
forecast_dates = seq(reference_date - 7, reference_date + 21, by = 7)
quantiles_vector = c(0.025, 0.1, 0.25, 0.5, 0.75, 0.9, 0.975)

last_update = as_date(df_target_data$time[1])
gap = (reference_date - last_update) / 7 - 1
season_names = unique(df_target_data_all$Season)
