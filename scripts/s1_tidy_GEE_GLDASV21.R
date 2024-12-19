pacman::p_load(
  Ipaper, data.table, dplyr, lubridate, 
  stringr, tidyfst
)

f = "data/SM_GLDAS_V21_3hourly_2018.csv"

tidy_ERA5L <- function(f) {
  fout = gsub(".csv", ".fst", f)
  if (file.exists(fout)) return()
  
  df = fread(f)
  dat = df[, .(
    time = str_sub(`system:index`, 2, 12),
    site,
    # Es = evaporation_from_bare_soil_hourly,
    # Ec = evaporation_from_vegetation_transpiration_hourly,
    ET = Evap_tavg,
    SM1 = SoilMoi0_10cm_inst, 
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
  tidy_ERA5L(f)
}
