% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setup_roxygen.R
\name{setup_roxygen}
\alias{setup_roxygen}
\title{Set up roxygen documentation for all tidy data sets using the dictionary}
\usage{
setup_roxygen()
}
\value{
NULL. This function creates documentation files inside "R/". Error if
tidy data cannot be found.
}
\description{
Creates or updates Roxygen documentation for all tidy data sets found
in the dictionary file.

When first run, this function creates the Roxygen documentation with placeholders
for the title and description field. The dictionary should include columns for
directory, file name, variable name, variable type, and description. This
function generates Roxygen comments with this information, facilitating
consistent and thorough documentation for your data sets.

When re-run this function, this function updates only the variable description entries
in the Roxygen documentation files within R/ directory. The title and description fields remain
unchanged.
}
\examples{
\dontshow{
temppkg <- tempdir()
devtools::create(temppkg, open=FALSE)
.old_wd <- setwd(temppkg)
}
\dontrun{
setup_dictionary()
# Once the dictionary is created, go to data-raw/dictionary.csv and complete the column description.
setup_roxygen()
}
\dontshow{
setwd(.old_wd)
}

}
