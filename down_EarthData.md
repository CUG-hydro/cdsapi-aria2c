# 下载EarthData数据

在[earthdata](https://earthdata.nasa.gov/data/catalog)中检索所需的数据，生成下载链接，使用`aria2c`下载数据。

- <https://earthdata.nasa.gov/data/catalog>

## GLDAS V21

```bash
aria2c -j4 -c -d GLDASV21 -i subset_GLDAS_NOAH025_3H_2.1_20241218_053106__rem.txt --http-user janekong --http-passwd ***
```
