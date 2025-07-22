#' Release the data package on GitHub and update relevant metadata
#'
#' @param owner
#'
#' @return
#' @export
#'
#' @examples
release_package <- function(owner = "openwashdata"){
  # Release to GitHub
  pkgname <-  get_pkgname()
  title <- desc::desc_get("Title")
  repo <- sprintf("/users/%s/%s/releases", owner, pkgname)

  version <- desc::desc_get("Version")
  tag <- paste0("v", version)
  release_name <- paste(pkgname, tag, ":", title)
  release_query <- paste("POST", repo)
  gh::gh(release_query,
         tag_name = tag,
         name = release_name) #refer to: https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28

  # Append to owd gsheet
  append_metadata_gsheet(pkgname = pkgname)
  # metadata_sheet |> sheet_append(row)

  # Post an issue to website repo
  gh::gh("POST /repos/openwashdata/website/issues",
         title = "[dataset released] update on data page",
         body = sprintf("[`%s`](https://openwashdata.github.io/%s/) is published.
                        The metadata google sheet is updated.
                        Please update the data page of the website.",
                        pkgname, pkgname))

  # Post an issue to newsletter
  gh::gh("POST /repos/openwashdata-dev/newsletter/issues",
         title = "[dataset released] add to next newsletter",
         body = sprintf("```[`%s`](https://openwashdata.github.io/%s/): %s.```",
                        pkgname, pkgname, title))
}

#' Append to openwashdata data package metadata google spreadsheet (for website data page)
#'
#' @param pkgname Name of the data package repository, e.g., washopenresearch
#'
#' @return
#' @export
#'
#' @examples
append_metadata_gsheet <- function(pkgname){
  sheet_id <- "1vtw16vpvJbioDirGTQcy0Ubz01Cz7lcwFVvbxsNPSVM"
  metadata_sheet <- googlesheets4::read_sheet(sheet_id)
  data_source <- select.list(choices = c("academic", "ngo", "government", "other"),
                        title = "What is the source of the data?")
  difficulty <- select.list(choices = c("low", "medium", "high"),
                            title = "What is the level of difficulty in terms of tidying this dataset?")
  cat("Which national geographical location does the datase cover?\nEnter \"Global\" if the dataset covers more than a country.")
  location <- readline(prompt = "Input: ")
  row <- data.frame(
    id	= max(metadata_sheet$id, na.rm = TRUE) + 1,
    pkg_name	= pkgname,
    maintainer = gh::gh_whoami()$login,
    source = data_source,
    difficulty = difficulty,
    status = "published",
    description = desc::desc_get("Title"),
    location = location,
    date_published = desc::desc_get("Date"),
    link_github = sprintf("<https://github.com/openwashdata/%s>", pkgname),
    link_pkg_website = sprintf("<https://openwashdata.github.io/%s>", pkgname),
    row.names = NULL
  )
  print(t(row), quote = FALSE, right = FALSE)
  is_append <- usethis::ui_yeah(x = cat("\n", "Would you like to append the above information to the google sheet?"))
  if(is_append){
    googlesheets4::sheet_append(sheet_id,
                                row)
    usethis::ui_done("Added to data package metadata google sheet.")
  }
}
