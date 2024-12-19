pacman::p_load(
  Ipaper, data.table, dplyr, lubridate, 
  stringr, tidyfst
)

df = fread("data/SM_ERA5L_hourly_2018.csv")

tidy_data <- function(f) {
  fout = gsub(".csv", ".fst", f)
  if (file.exists(fout)) return()
  
  df = fread(f)
  dat = df[, .(
    time = str_sub(`system:index`, 1, 11),
    site,
    Es = evaporation_from_bare_soil_hourly,                # [m]
    Ec = evaporation_from_vegetation_transpiration_hourly, # [m]
    ET = total_evaporation_hourly,                         # [m]
    SM1 = volumetric_soil_water_layer_1, # 0-7cm, [m^3/m^3]
    SM2 = volumetric_soil_water_layer_2, # 7-28cm, [m^3/m^3]
    SM3 = volumetric_soil_water_layer_3, # 28-100cm, [m^3/m^3]
    SM4 = volumetric_soil_water_layer_4  # 100-289cm, [m^3/m^3]
  )]
  dat[, time := ymd_h(time)]
  export_fst(dat, fout)
}

fs = dir2("data", "SM_ERA5L_hourly_.*.csv")[-1]

foreach(f = fs, i = icount()) %do% {
  print(f)
  tidy_data(f)
}
