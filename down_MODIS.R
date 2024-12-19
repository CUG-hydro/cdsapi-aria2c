pacman::p_load(httr, xml2, glue)

get_url <- function(year = 2021) {
  url <- glue("https://e4ftl01.cr.usgs.gov/MOTA/MCD12C1.061/{year}.01.01/")
  p <- GET(url) %>% content()
  name <- xml_find_all(p, "//a")[9] %>% xml_text()
  paste0(url, name)
}

urls <- sapply(2001:2023, get_url)
writeLines(urls, "urls.txt")

user = "janekong"
pwd = "***"
shell(glue("aria2c -x4 -s4 -j4 -c -i urls.txt --http-user {user} --http-passwd {pwd}"))
