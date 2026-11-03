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
#   publisher          the publisher sentence of the site footer (Markdown)
#   home               the website of the organisation (navbar link, README
#                      line, publisher url in the JSON-LD)
#   catalog            the data catalogue of the organisation
#                      (includedInDataCatalog in the JSON-LD)
#   community          the text of the community block in the site sidebar
#                      (Markdown)
#   parent-organizations
#                      the organisations above the publisher, nearest first,
#                      as "Name <url>" entries separated by semicolons
#                      (parentOrganization chain in the JSON-LD; a ror.org
#                      URL becomes the @id) (#153)
#   pages-domain       the domain of the site, when it is not <org>.github.io
#   version            the washr version that last ran update_description()
#   brand              the brand ref that use_brand() last installed
#   withheld           the sentence on data left out of the package, which
#                      closes the statement of data_availability_statement()
# A field set to "none" switches its feature off. update_description() writes
# the first ten with their defaults and the version; use_brand() writes the
# brand. pages-domain and withheld are only ever written by hand.
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
# or a publisher it does not have, analytics, a website, a catalogue and a
# community it does not own).
washr_defaults <- function(org = "openwashdata") {
  if (identical(tolower(org), "openwashdata")) {
    c(
      "funding" = "This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).",
      "analytics-domain" = "openwashdata.github.io",
      "doi-provider" = "zenodo",
      "zenodo-community" = "openwashdata",
      "brand-source" = "openwashdata/brand",
      "publisher" = "Published by [openwashdata](https://openwashdata.org), a project of [Global Health Engineering](https://ghe.ethz.ch/) at ETH Zurich.",
      "home" = "https://openwashdata.org",
      "catalog" = "https://openwashdata.org/pages/gallery/data/",
      "community" = "This package is part of [openwashdata](https://openwashdata.org). Browse the [data catalogue](https://openwashdata.org/pages/gallery/data/) or get the [newsletter](https://openwashdata.org/pages/newsletter/).",
      "parent-organizations" = "Global Health Engineering <https://ghe.ethz.ch/>; Institute of Design, Materials and Fabrication <https://ror.org/03zqk4w67>; ETH Zurich <https://ror.org/05a28rw58>"
    )
  } else {
    c(
      "funding" = "none",
      "analytics-domain" = "none",
      "doi-provider" = "zenodo",
      "zenodo-community" = "none",
      "brand-source" = "none",
      "publisher" = "none",
      "home" = "none",
      "catalog" = "none",
      "community" = "none",
      "parent-organizations" = "none"
    )
  }
}

# The value of a config field for this package: the field when it is set,
# else the default for the organisation of the package.
pkg_config <- function(key, file = ".") {
  washr_config(key, default = washr_defaults(pkg_org(file))[[key]], file = file)
}

# The parent-organizations field of the package as a list of entries, each
# with `name` and `url` (NULL when the entry names no URL), nearest
# organisation first. An empty list when the field is "none" (#153).
parent_organizations <- function(file = ".") {
  parse_parent_organizations(pkg_config("parent-organizations", file))
}

# The same for a value of the field as text.
parse_parent_organizations <- function(value) {
  if (!is_set(value)) return(list())
  entries <- trimws(strsplit(value, ";", fixed = TRUE)[[1]])
  entries <- entries[nzchar(entries)]
  lapply(entries, function(entry) {
    url <- regmatches(entry, regexpr("<[^>]*>", entry))
    name <- trimws(sub("<[^>]*>", "", entry))
    url <- if (length(url)) trimws(gsub("^<|>$", "", url)) else ""
    list(name = name, url = if (nzchar(url)) url else NULL)
  })
}

# TRUE for a ROR identifier written as a URL (https://ror.org/...).
is_ror_url <- function(url) {
  !is.null(url) && grepl("^https?://(www\\.)?ror\\.org/[0-9a-z]+/?$", url)
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

# The URL of the published site, as the package records it, or NULL. The url
# of _pkgdown.yml comes first, then the entry of the DESCRIPTION URL field on
# the pages domain (Config/washr/pages-domain, github.io by default). A
# GitHub repository URL is not a site and is passed over. The URL is returned
# as written. With `pkgdown = FALSE` only DESCRIPTION is read, which is what
# the JSON-LD uses. `path` is the package root.
pkg_site_url <- function(path = ".", pkgdown = TRUE) {
  is_site <- function(u) {
    length(u) == 1 && is.character(u) && !is.na(u) && nzchar(trimws(u)) &&
      is.na(normalise_github_url(u))
  }
  config <- file.path(path, "_pkgdown.yml")
  if (pkgdown && file.exists(config)) {
    url <- tryCatch(yaml::read_yaml(config)$url, error = function(e) NULL)
    if (is_site(url)) return(trimws(url))
  }
  desc_file <- file.path(path, "DESCRIPTION")
  urls <- tryCatch(desc::desc_get_urls(file = desc_file),
                   error = function(e) character())
  domain <- washr_config("pages-domain", default = "github.io", file = desc_file)
  urls <- urls[grepl(domain, urls, fixed = TRUE)]
  urls <- urls[vapply(urls, is_site, logical(1))]
  if (length(urls)) urls[[1]] else NULL
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
