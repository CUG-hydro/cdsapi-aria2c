// https://code.earthengine.google.com/dd020bec935c55d2e40108419008cfc4?noload=1

// print(points)
var pkgs = require('users/kongdd/pkgs:pkgs');
var bands_GLDAS = ['SoilMoi0_10cm_inst', 'SoilMoi10_40cm_inst', 'SoilMoi40_100cm_inst', 'SoilMoi100_200cm_inst', 'Evap_tavg'];
var bands_ERA5L = [
  'volumetric_soil_water_layer_1',
  'volumetric_soil_water_layer_2',
  'volumetric_soil_water_layer_3',
  'volumetric_soil_water_layer_4',
  'evaporation_from_bare_soil_hourly',
  'evaporation_from_vegetation_transpiration_hourly',
  'total_evaporation_hourly'
];


for (var year = 2018; year <= 2022; year++) {
  var filter = ee.Filter.calendarRange(year, year, "year");
  var _col_gldas_v21 = col_gldas_v21.filter(filter).select(bands_GLDAS);
  var _col_era5l = col_era5l.filter(filter).select(bands_ERA5L);

  var task = "SM_GLDAS_V21_3hourly_" + year;
  pkgs.col_extract_points(_col_gldas_v21, task, points);

  var task = "SM_ERA5L_hourly_" + year;
  pkgs.col_extract_points(_col_era5l, task, points);
}
