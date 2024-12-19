library(httr)
library(glue)
library(progress)
library(data.table)
library(magrittr)

get_key <- function() {
  infile = sprintf("%s/.cdsapirc", Sys.getenv("USERPROFILE"))
  key = read.table(infile)$V2[2]
}

key <- get_key()
# job: https://cds.climate.copernicus.eu/api/retrieve/v1/jobs/2f87df75-cfbc-4fb5-8f65-9538c8c8a707
query_fname <- function(job) {
  url <- glue("{job}?request=true")
  l <- GET(url, httr::add_headers("PRIVATE-TOKEN" = key)) %>% content()
  l$metadata$request$ids$target # filename
}

query_info <- function() {
  url = "https://cds.climate.copernicus.eu/api/retrieve/v1/jobs?limit=100&status=successful&request=true"
  res <- GET(url, httr::add_headers("PRIVATE-TOKEN" = key)) %>% content()

  n = length(res$jobs)
  cat(sprintf("Total %d jobs\n", n))

  RES = list()
  pb <- progress_bar$new(total = n)
  for (i in 1:n) {
    pb$tick()
    r = res$jobs[[i]]
    href = r$metadata$results$asset$value$href
    job <- r$links[[1]]$href # rel = "monitor"
    file = query_fname(job)
    if (is.null(file)) file = "" # basename(href)
    d = data.table(file, url = href)
    RES[[i]] <- d
  }
  RES <- do.call(rbind, RES)
  RES
}

write_url <- function(d_url, outfile = "urls.txt", overwrite = TRUE) {
  urls <- d_url[file != "" & url != "", ] %$%
    sprintf("# %s \n%s\n\tout=%s", file, url, file)

  if (!file.exists(outfile) || overwrite) {
    if (file.exists(outfile)) file.remove(outfile)
    writeLines(urls, outfile)
  }
  invisible()
}


target_last = "ERA5L_SM_202212.nc" # 用于判断结束时间
while (1) {
  d_url <- query_info()
  write_url(d_url)
  
  cmd <- "aria2c -c -x 5 -s 5 -j 5 --file-allocation=none -i urls.txt -d Z:/ERA5L/China/SM_hourly"
  shell(cmd, wait = TRUE)
  
  # 如果所有文件都下载完了
  if (target_last %in% d_url$file) break  

  Sys.sleep(600) # sleep 10mins
}
