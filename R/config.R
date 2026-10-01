# Values that differ between publishing groups live in DESCRIPTION as
# Config/washr/<key> fields (#81), so a group other than openwashdata changes
# them by editing DESCRIPTION and no function carries its own copy.
#
# The fields:
#   funding            the funding sentence of the site sidebar (Markdown)
#   analytics-domain   the Plausible domain of the analytics header
#   doi-provider       where releases get their DOI; decides the DOI badge
#   zenodo-community   the Zenodo community of the record (.zenodo.json)
#   brand-source       the GitHub repository of the brand (use_brand())
#   pages-domain       the domain of the site, when it is not <org>.github.io
#   version            the washr version that last ran update_description()
#   brand              the brand ref that use_brand() last installed
# A field set to "none" switches its feature off. update_description() writes
# the first five with their defaults and the version; use_brand() writes the
# brand. pages-domain is only ever written by hand.
#
# The GitHub organisation, the repository URL, the license and the publisher
# are not config: they are read from the standard DESCRIPTION fields.

# washr_config() is the one reader of the fields. It returns the value of
# Config/washr/<key>, or `default` when the field is absent or empty. `file`
# is a package root or the path of a DESCRIPTION file.
washr_config <- function(key, default = NULL, file = ".") {
  value <- desc::desc_get_field(paste0("Config/washr/", key), default = "",
                                file = file)
  value <- trimws(gsub("\\s+", " ", value))
  if (identical(value, "")) default else value
}

# The defaults update_description() writes. openwashdata packages get the
# openwashdata values. A package of another organisation gets "none" for the
# values that would otherwise make a false statement on its site (a funder
# it does not have, analytics and a community it does not own).
washr_defaults <- function(org = "openwashdata") {
  if (identical(tolower(org), "openwashdata")) {
    c(
      "funding" = "This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).",
      "analytics-domain" = "openwashdata.github.io",
      "doi-provider" = "zenodo",
      "zenodo-community" = "openwashdata",
      "brand-source" = "openwashdata/brand"
    )
  } else {
    c(
      "funding" = "none",
      "analytics-domain" = "none",
      "doi-provider" = "zenodo",
      "zenodo-community" = "none",
      "brand-source" = "none"
    )
  }
}

# The value of a config field for this package: the field when it is set,
# else the default for the organisation of the package.
pkg_config <- function(key, file = ".") {
  washr_config(key, default = washr_defaults(pkg_org(file))[[key]], file = file)
}

# TRUE when a config value switches its feature on.
is_set <- function(value) {
  !is.null(value) && !identical(tolower(value), "none")
}

# The GitHub organisation of the package, from the repository in the URL
# field of DESCRIPTION. openwashdata when DESCRIPTION names no repository
# yet, which is the state before update_description() has run.
pkg_org <- function(file = ".") {
  repo <- github_repo_url(file)
  if (is.null(repo)) "openwashdata" else basename(dirname(repo))
}

# The repository URL of the package, from DESCRIPTION, or the conventional
# one under the organisation when DESCRIPTION names none yet.
pkg_repo_url <- function(file = ".") {
  repo <- github_repo_url(file)
  if (!is.null(repo)) return(repo)
  paste0("https://github.com/", pkg_org(file), "/",
         desc::desc_get_field("Package", file = file))
}

# The URL of the pkgdown site: https://<org>.github.io/<package>/, or under
# Config/washr/pages-domain when the site lives elsewhere.
pkg_pages_url <- function(file = ".") {
  paste0("https://", pkg_pages_domain(file), "/",
         desc::desc_get_field("Package", file = file), "/")
}

pkg_pages_domain <- function(file = ".") {
  washr_config("pages-domain",
               default = paste0(tolower(pkg_org(file)), ".github.io"),
               file = file)
}

# A value as a YAML scalar on one line: as it is when YAML reads it back
# unchanged, else double quoted.
yaml_scalar <- function(x) {
  plain <- tryCatch(yaml::yaml.load(paste0("k: ", x))$k, error = function(e) NULL)
  if (identical(plain, x)) return(x)
  paste0('"', gsub('"', '\\"', gsub("\\", "\\\\", x, fixed = TRUE), fixed = TRUE), '"')
}
