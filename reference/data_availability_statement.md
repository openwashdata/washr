# Draft the citation and data availability text for an article

`data_availability_statement()` drafts the text that the authors of an
article need once the data package has a DOI: the reference list entry
in APA style, the data availability statement and the in-text citation.
All three come from metadata the package already holds, so they are
ready the moment the DOI is on file.

The sources are:

|  |  |
|----|----|
| Part | Source |
| authors | `Authors@R` in DESCRIPTION, roles `aut` and `cre`, in their order (the same persons as `CITATION.cff` and `.zenodo.json`) |
| year | `date-released` in `CITATION.cff`, else `Date` in DESCRIPTION |
| title, version, licence | `Package`, `Title`, `Version`, `License` in DESCRIPTION |
| DOI | `doi` in `CITATION.cff`, which [`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md) writes |
| repository | the GitHub repository in the `URL` field of DESCRIPTION |
| website | the `url` in `_pkgdown.yml`, else the `github.io` entry of the `URL` field |
| download formats | the CSV and Excel files in `inst/extdata` |
| withheld data | `Config/washr/withheld` in DESCRIPTION |

## Usage

``` r
data_availability_statement(subject = "The data", clipboard = FALSE)
```

## Arguments

- subject:

  The opening words of the statement, which name the data the article
  uses. Defaults to `"The data"`, which gives "The data supporting this
  study are openly available ...". Write it for the article, e.g.,
  `"The household survey data"`.

- clipboard:

  Logical. Copy the reference entry and the statement to the clipboard
  as well? Defaults to `FALSE`. Needs the clipr package.

## Value

A named character vector of class `washr_data_availability` with the
elements `reference`, `statement` and `in_text`. Printing it shows the
three parts.

## Details

The reference entry follows APA 7: authors as "Family, I. I.", with "&"
before the last one, and with 21 or more authors the first 19, an
ellipsis and the last author. An author without a family name is an
organisation and keeps its full name. The entry ends with the repository
URL ("Available at ..."). The in-text citation names one author, two
authors joined by "&", or the first author followed by "et al." for
three or more.

The statement names the licence, the package and its version, the DOI
and the in-text citation. When the package has a website, a second
sentence points to it for the CSV and Excel downloads found in
`inst/extdata`. When some data was left out of the package, write one
sentence that says what and why into DESCRIPTION, for example
`Config/washr/withheld: Household coordinates are not included, to protect the privacy of the respondents.`
The sentence closes the statement word for word.

The function stops when `CITATION.cff` carries no DOI yet: run
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
with the DOI of the Zenodo record first. Run it on the released version;
a development version (such as `1.0.0.9000`) gives a warning, because
the text would name a version that is not archived.

## See also

Before:
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
with the DOI of the Zenodo record.

Other publishing functions:
[`check_publication_readiness()`](https://openwashdata.github.io/washr/reference/check_publication_readiness.md),
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md),
[`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md),
[`update_website()`](https://openwashdata.github.io/washr/reference/update_website.md),
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data_availability_statement()

# Name the data the article uses, and copy the text to the clipboard
data_availability_statement(subject = "The household survey data",
                            clipboard = TRUE)
} # }
```
