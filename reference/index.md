# Package index

## Using washr

### Setting up your data repository

- [`setup_rawdata()`](https://openwashdata-dev.github.io/washr/reference/setup_rawdata.md)
  : Create the data-raw directory with a data-processing.R template

### Documenting your data

Helper functions to document both your dataset(s) and functions

- [`setup_dictionary()`](https://openwashdata-dev.github.io/washr/reference/setup_dictionary.md)
  : Create a dictionary file for tidy data sets
- [`setup_roxygen()`](https://openwashdata-dev.github.io/washr/reference/setup_roxygen.md)
  : Set up roxygen documentation for all tidy data sets using the
  dictionary

### Adding metadata

Helper functions to add metadata

- [`update_citation()`](https://openwashdata-dev.github.io/washr/reference/update_citation.md)
  : Update the citation file for the dataset.
- [`update_description()`](https://openwashdata-dev.github.io/washr/reference/update_description.md)
  : Update the DESCRIPTION file to conform with openwashdata standards
- [`update_metadata()`](https://openwashdata-dev.github.io/washr/reference/update_metadata.md)
  **\[experimental\]** : Generate and embed the schema.org metadata of
  the data package

### Publishing your data

Helper functions to communicate your data

- [`setup_readme()`](https://openwashdata-dev.github.io/washr/reference/setup_readme.md)
  : Generate the README RMarkdown file
- [`setup_website()`](https://openwashdata-dev.github.io/washr/reference/setup_website.md)
  : Set up a pkgdown website for the data package
- [`use_brand()`](https://openwashdata-dev.github.io/washr/reference/use_brand.md)
  : Install or refresh the openwashdata brand in the active package
