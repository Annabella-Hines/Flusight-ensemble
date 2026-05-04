### Script to adjust flusight ensemble for submission to the Metrocast hub

## path to flusight ensemble
filedirec <- paste0("C:/Users/",Sys.info()["user"],"/Desktop/GitHub/FluSight-forecast-hub/model-output/")

## pull correct ref date
forecast_date <- current_ref_date <- lubridate::ceiling_date(Sys.Date(), "week") - days(1)

## read in correct file
ens <- read.csv(paste0(filedirec,"FluSight-ensemble/", forecast_date,"-FluSight-ensemble.csv"))

##  filter to only ed visits, adjust target name, horizon, and quantiles
ed <- ens %>% filter(target=="wk inc flu prop ed visits") %>% 
  mutate(target="Flu ED visits pct") %>% 
  filter(horizon!=-1) %>% 
  filter(output_type_id %in% c(0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975))

## read in location file
loc <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/auxiliary-data/locations.csv")

## keep only the accepted locations
#colorado, georgia, indiana, maine, maryland, massachusetts, minnesota, south-carolina, texas, utah, virginia, north-carolina, oregon
states_keep <- c(
  "Colorado", "Georgia", "Indiana", "Maine", "Maryland",
  "Massachusetts", "Minnesota", "South Carolina",
  "Texas", "Utah", "Virginia", "North Carolina", "Oregon")

loc_filtered <- loc %>%
  filter(location_name %in% states_keep) %>%
  mutate(state_slug = location_name %>%
      str_to_lower() %>%
      str_replace_all(" ", "-")) %>%
  select(location, location_name, state_slug)


ed_joined <- ed %>%
  inner_join(loc_filtered, by = "location")

ed_final <- ed_joined %>%
  select(-location, -location_name, location = state_slug)%>%
  relocate(location, .after = 1) %>% mutate(value=value*100)


metro_path <- paste0("C:/Users/", Sys.info()["user"],"/Desktop/GitHub/flu-metrocast/model-output/")

write.csv(ed_final,
  paste0(metro_path, "FluSight-ensemble/", forecast_date, "-FluSight-ensemble.csv"),
  row.names = FALSE)


