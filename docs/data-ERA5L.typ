// #import "../typst/lib.typ": *
#import "@preview/modern-cug-report:0.1.0": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "ERA5-Land数据下载")
#counter(heading).update(1)
#set par(leading: 1.24em)
#codly(number-format: none)

== ERA5-Land数据下载

ERA5-Land是第一梯队的再分析资料，具有较高的质量。
这里展示的是如何下载ERA5-Land中国区域的土壤水分数据。

#box-red([
数据链接：
https://cds.climate.copernicus.eu/datasets/reanalysis-era5-land?tab=download；

python软件包安装与api配置：https://cds.climate.copernicus.eu/how-to-api。
])

== ERA5-Land数据下载说明
#box-blue([
  这里实现的是#highlight()[批量提交下载任务]，后面可在浏览器下载文件。
])

```py
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
```

== 变量单位

- volumetric_soil_water_layer_1: m3 m-3
