# Load packages
library(epinowcast)
library(data.table)
library(lubridate)
library(here)

# Load and filter germany hospitalisations
# See {epinowcast} docs for more on this data
nat_germany_hosp <- germany_covid19_hosp[location == "DE"][age_group %in% "00+"]
nat_germany_hosp <- enw_filter_report_dates(
  nat_germany_hosp,
  latest_date = "2021-10-01"
)

# Make sure observations are complete
nat_germany_hosp <- enw_complete_dates(
  nat_germany_hosp,
  by = c("location", "age_group")
)

# Add incidence
nat_germany_hosp <- nat_germany_hosp |>
  enw_add_incidence()

# Rewrite the following to use nat_germany_hosp
# Make a day of week indicator
nat_germany_hosp[, day_of_week := lubridate::wday(report_date, label = TRUE)]

# Take a 7 day rolling sum of reports to get the number reported weekly by day
nat_germany_hosp <- nat_germany_hosp[, confirm := new_confirm] |>
  # Here we use an internal epinowcast function for ease that is hard
  # coded to sum confirm
  epinowcast:::aggregate_rolling_sum(
    internal_timestep = 7, by = "reference_date"
  )

# Set all reports that aren't on a Thursday to be zero
nat_germany_hosp[, confirm := ifelse(
  day_of_week != "Thu",
  0,
  confirm
)]

# Make an indicator that it isn't Thursday - Science has never been this hard
nat_germany_hosp[, not_thursday := ifelse(
  day_of_week != "Thu",
  1,
  0
)]

# Update cumulative reported cases from incidence
nat_germany_hosp <- nat_germany_hosp[,
 confirm := cumsum(confirm), by = "reference_date"
] |>
  enw_add_incidence()

# Make a retrospective dataset
retro_nat_germany <- enw_filter_report_dates(
  nat_germany_hosp,
  remove_days = 40
)
retro_nat_germany <- enw_filter_reference_dates(
  retro_nat_germany,
  include_days = 60
)

# Get latest observations for the same time period
latest_obs <- nat_germany_hosp[day_of_week %in% "Thu"] |>
  enw_latest_data()

fwrite(retro_nat_germany, here("data", "synthetic-weekly-data.csv"))
fwrite(latest_obs, here("data", "latest-synthetic-weekly-data.csv"))