pacman::p_load(
  Ipaper, data.table, dplyr, lubridate, 
  stringr, tidyfst
)

f = "data/SM_GLDAS_V21_3hourly_2018.csv"

tidy_data <- function(f) {
  fout = gsub(".csv", ".fst", f)
  if (file.exists(fout)) return()
  
  df = fread(f)
  dat = df[, .(
    time = str_sub(`system:index`, 2, 12),
    site,
    ## 需补充下载
    # Tair_f_inst,               # Air temperature, [K]
    # Tveg_tavg,                 # Transpiration (植被蒸腾), [W/m^2]
    # ECanop_tavg,               # Canopy water evaporation (截留蒸发), [W/m^2]
    # ESoil_tavg,                # Evaporation from soil, [W/m^2]
    ET = Evap_tavg,            # Evapotranspiration, [kg/m^2/s]
    SM1 = SoilMoi0_10cm_inst,  # soil moisture, [kg/m^2] = [mm]
    SM2 = SoilMoi10_40cm_inst,
    SM3 = SoilMoi40_100cm_inst,
    SM4 = SoilMoi100_200cm_inst
  )]
  dat[, time := ymd_h(time)]
  export_fst(dat, fout)
}
# save(dat, file = "a.rda")
fs = dir2("data", "SM_GLDAS_V21_3hourly_.*.csv")[-1]

foreach(f = fs, i = icount()) %do% {
  print(f)
  tidy_data(f)
}
