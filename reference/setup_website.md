# Set up a pkgdown website for the data package

`setup_website()` writes the openwashdata pkgdown configuration and
builds the site from the package documentation and README.md. The
configuration comes from the washr template: the Pages URL as the site
URL, the openwashdata analytics header, the funding sidebar, the authors
footer, and a reference index with one entry per data object in `data/`.

The function is safe to re-run. An existing `_pkgdown.yml` is kept as it
is and only the site is rebuilt, so hand edits and the brand wiring from
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)
survive. The example article is created once.

By default the built `docs/` folder is tracked in git, which is how
openwashdata packages publish their site from `main`. When the package
deploys through the pkgdown GitHub Actions workflow instead
(`.github/workflows/pkgdown.yaml` exists), `docs/` stays ignored.

## Usage

``` r
setup_website(has_example = FALSE, track_docs = NULL)
```

## Arguments

- has_example:

  Logical. Should the pkgdown website include a vignette page for
  writing an example? Defaults to FALSE.

- track_docs:

  Logical. Remove `docs` from `.gitignore` so the built site is
  committed? Defaults to `TRUE` unless a pkgdown workflow exists under
  `.github/workflows/`.

## Value

NULL. Error if no README file is found.

## See also

Before:
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md).
Next:
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)
for the brand, and
[`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
once the release has a DOI.

Other publishing functions:
[`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md),
[`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up the pkgdown website including a vignette page
 setup_website(has_example = TRUE)
} # }
```
