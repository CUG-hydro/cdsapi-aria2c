import cdsapi


client = cdsapi.Client(wait_until_complete=False)

def down_ym(year=2022, month=1):
    dataset = "reanalysis-era5-land"
    request = {
        "variable": [
            "volumetric_soil_water_layer_1",
            "volumetric_soil_water_layer_2",
            "volumetric_soil_water_layer_3",
            "volumetric_soil_water_layer_4"
        ],
        "year": year,
        "month": "%02d" % month,
        "day": ["%02d" % day for day in range(1, 32)],
        "time": ["%02d" % day for day in range(0, 24)],
        "target": "ERA5L_SM_%d%02d.nc" % (year, month),
        "data_format": "netcdf",
        "download_format": "unarchived",
        "area": [55, 70, 15, 140]
    }
    print("running: %s\n" % request["target"])
    client.retrieve(dataset, request, None)  # .download()

def down_year(year):
    for month in range(1, 13):
        down_ym(year, month)

if __name__ == "__main__":
    for year in range(2018, 2023):
        down_year(year)
