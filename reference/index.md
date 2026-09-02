# Package index

## Set up the data package

Scaffold the raw data folder and the processing script

- [`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md)
  : Create the data-raw directory with a data-processing.R template

## Document the data

The dictionary and the roxygen documentation it feeds

- [`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md)
  : Create a dictionary file for tidy data sets
- [`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md)
  : Set up roxygen documentation for all tidy data sets using the
  dictionary

## Describe the package

DESCRIPTION as the canonical source, and the schema.org metadata derived
from it (experimental)

- [`update_description()`](https://openwashdata.github.io/washr/reference/update_description.md)
  : Update the DESCRIPTION file to conform with openwashdata standards
- [`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
  **\[experimental\]** : Generate and embed the schema.org metadata of
  the data package

## Publish

README, website, brand, and the citation with its DOI

- [`setup_readme()`](https://openwashdata.github.io/washr/reference/setup_readme.md)
  : Generate the README RMarkdown file
- [`setup_website()`](https://openwashdata.github.io/washr/reference/setup_website.md)
  : Set up a pkgdown website for the data package
- [`use_brand()`](https://openwashdata.github.io/washr/reference/use_brand.md)
  : Install or refresh the openwashdata brand in the active package
- [`update_citation()`](https://openwashdata.github.io/washr/reference/update_citation.md)
  : Update the citation file for the dataset.
