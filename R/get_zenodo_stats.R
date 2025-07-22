library(httr)

get_community_records <- function(name){
  community_page <- httr::content(httr::GET(sprintf("https://zenodo.org/api/communities/%s", name)))
  records_url <- community_page$links$records
  records_url_content <- httr::content(httr::GET(records_url))
  records_list <- records_url_content$hits$hits
  # add request datetime
  return(records_list)
}

get_record_by_doi <- function(doi){
  id <- strsplit(doi, "zenodo.")[[1]][2]
  record <- httr::content(httr::GET(sprintf("https://zenodo.org/api/records/%s", id)))
  # add request datetime
  return(record)
}


get_zenodo_stats <- function(records_list){
  pkgname <- c()
  doi <- c()
  unique_downloads <- c()
  unique_views <- c()

  for (package in owd) {
    pkg <- sub("-v[0-9]\\.[0-9]\\.[0-9]\\.zip", "", basename(package$files[[1]]$key))
    pkgname <- c(pkgname, pkg)
    doi <- c(doi, package$doi)
    unique_downloads <- c(unique_downloads, package$stats$unique_downloads)
    unique_views <- c(unique_views, package$stats$unique_views)
  }

  zenodo_stats <- data.frame(
    pkg_name = pkgname,
    doi = doi,
    unique_downloads = unique_downloads,
    unique_views = unique_views,
    download_per_view = unique_downloads/unique_views
  )
  return(zenodo_stats)
}

get_zenodo_community_stats <- function(name){
  records_list <- get_community_records(name)
  community_stats <- get_zenodo_stats(records_list)
  return(community_stats)
}
