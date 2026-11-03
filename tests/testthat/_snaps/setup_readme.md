# setup_readme() keeps the README of a single dataset as it was (#103)

    Code
      cat(readme, sep = "\n")
    Output
      ---
      output: github_document
      always_allow_html: true
      editor_options: 
        markdown: 
          wrap: 72
        chunk_output_type: console
      ---
      
      <!-- README.md is generated from README.Rmd. Please edit that file -->
      
      ```{r, include = FALSE}
      knitr::opts_chunk$set(
        collapse = TRUE,
        comment = "#>",
        fig.path = "man/figures/README-",
        out.width = "100%",
        message = FALSE,
        warning = FALSE,
        fig.retina = 2,
        fig.align = 'center'
      )
      ```
      
      # PKGNAME
      
      <!-- badges: start -->
      
      [![License: CC BY
      4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
      [![R-CMD-check](https://github.com/openwashdata/PKGNAME/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/openwashdata/PKGNAME/actions/workflows/R-CMD-check.yaml)
      
      <!-- badges: end -->
      
      The goal of PKGNAME is to ...
      
      ## Installation
      
      You can install the development version of PKGNAME from
      [GitHub](https://github.com/) with:
      
      ``` r
      # install.packages("devtools")
      devtools::install_github("openwashdata/PKGNAME")
      ```
      
      ```{r}
      ## Run the following code in console if you don't have the packages
      ## install.packages(c("dplyr", "knitr", "readr", "stringr", "gt", "kableExtra"))
      library(dplyr)
      library(knitr)
      library(readr)
      library(stringr)
      library(gt)
      library(kableExtra)
      ```
      
      Alternatively, you can download the individual datasets as a CSV or XLSX
      file from the table below.
      
      1.  Click Download CSV. A window opens that displays the CSV in
          your browser.
      2.  Right-click anywhere inside the window and select "Save Page As...".
      3.  Save the file in a folder of your choice.
      
      ```{r, echo=FALSE, message=FALSE, warning=FALSE}
      
      # A release links the files of its own tag, so a citation of that version
      # gets the same files later; a development version links the main branch.
      version <- read.dcf("DESCRIPTION", fields = "Version")[[1]]
      ref <- if (grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", version)) paste0("v", version) else "main"
      extdata_path <- paste0("https://github.com/openwashdata/PKGNAME/raw/", ref, "/inst/extdata/")
      
      read_csv("data-raw/dictionary.csv") |> 
        distinct(file_name) |> 
        dplyr::mutate(file_name = str_remove(file_name, ".rda")) |> 
        dplyr::rename(dataset = file_name) |> 
        mutate(
          CSV = paste0("[Download CSV](", extdata_path, dataset, ".csv)"),
          XLSX = paste0("[Download XLSX](", extdata_path, dataset, ".xlsx)")
        ) |> 
        knitr::kable()
      
      ```
      
      ## Data
      
      The package provides access to ...
      
      ```{r}
      library(PKGNAME)
      ```
      
      ### d1
      
      The dataset `d1` contains data about ... It has
      `r nrow(d1)` observations and `r ncol(d1)`
      variables
      
      ```{r}
      d1 |> 
        head(3) |> 
        gt::gt() |>
        gt::as_raw_html()
      ```
      
      For an overview of the variable names, see the following table.
      
      ```{r echo=FALSE, message=FALSE, warning=FALSE}
      readr::read_csv("data-raw/dictionary.csv") |>
        dplyr::filter(file_name == "d1.rda") |>
        dplyr::select(variable_name:description) |> 
        knitr::kable() |> 
        kableExtra::kable_styling("striped") |> 
        kableExtra::scroll_box(height = "200px")
      ```
      
      ## Example
      
      Describe here what the plot below shows and why it is a useful first look
      at the data.
      
      ```{r}
      library(PKGNAME)
      # install.packages("ggplot2")
      # library(ggplot2)
      
      # A first plot of the data: replace the aesthetics with variables from
      # d1, then uncomment the block and the library call above.
      # d1 |>
      #   ggplot(aes(x = , y = )) +
      #   geom_point() +
      #   labs(x = "", y = "", title = "")
      ```
      
      ## License
      
      Data are available as
      [CC-BY](https://github.com/openwashdata/PKGNAME/blob/main/LICENSE.md).
      
      ## Citation
      
      Published by openwashdata, <https://openwashdata.org>.
      
      ```{r, echo=FALSE, results='asis'}
      # How to cite in plain text, so the DOI and the version also reach readers
      # of README.md and the llms.txt that pkgdown builds from it.
      cff <- if (file.exists("CITATION.cff")) readLines("CITATION.cff", warn = FALSE) else character()
      cff_value <- function(key) {
        line <- grep(paste0("^", key, ":"), cff, value = TRUE)
        if (length(line)) gsub("^[^:]+:\\s*['\"]?|['\"]?\\s*$", "", line[[1]]) else ""
      }
      doi <- cff_value("doi")
      if (nzchar(doi)) {
        cat("Cite version ", cff_value("version"), " of PKGNAME with the DOI ",
            "[", doi, "](https://doi.org/", doi, "). ", sep = "")
      }
      cat("The full citation with BibTeX and the authors with their ORCID iDs are on the ",
          "[authors page](https://openwashdata.github.io/PKGNAME/authors.html), and ",
          "[CITATION.cff](https://github.com/openwashdata/PKGNAME/blob/main/CITATION.cff) holds the same in ",
          "machine readable form.\n\n", sep = "")
      based_on <- read.dcf("DESCRIPTION", fields = "X-schema.org-isBasedOn")[[1]]
      if (!is.na(based_on)) {
        sources <- sub("^(https?://(dx\\.)?doi\\.org/|doi:\\s*)", "",
                       trimws(strsplit(based_on, ",")[[1]]), ignore.case = TRUE)
        cat("The data were first published in ",
            paste0("<https://doi.org/", sources, ">", collapse = ", "),
            ". Please cite that source as well.\n\n", sep = "")
      }
      ```
      
      Please cite this package using:
      
      ```{r}
      citation("PKGNAME")
      ```

