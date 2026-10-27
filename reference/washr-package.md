# washr: Publication Toolkit for Water, Sanitation and Hygiene (WASH) Data

A toolkit to set up an R data package in a consistent structure.
Automates tasks like tidy data export, data dictionary documentation,
README and website creation, and citation management.

## Messages and return values

Every function reports through cli with three kinds of lines: a success
line for a file it wrote, an info line for something it kept or skipped,
and an arrow line for the next step that is left to you. Each function
returns what it wrote, invisibly: the path of the file, or the paths
when there are several.
[`update_metadata()`](https://openwashdata.github.io/washr/reference/update_metadata.md)
returns the metadata as a list.

Set `options(washr.quiet = TRUE)` to silence these lines, for example in
scripts. Warnings and errors are never silenced.

## See also

Useful links:

- <https://openwashdata.github.io/washr/>

- Report bugs at <https://github.com/openwashdata/washr/issues>

## Author

**Maintainer**: Lars Schöbitz <lschoebitz@ethz.ch>
([ORCID](https://orcid.org/0000-0003-2196-5015))

Authors:

- Lars Schöbitz <lschoebitz@ethz.ch>
  ([ORCID](https://orcid.org/0000-0003-2196-5015))

- Mian Zhong <mzhong@ethz.ch>
  ([ORCID](https://orcid.org/0009-0009-4546-7214))

- Margaux Götschmann <margauxg@ethz.ch>
  ([ORCID](https://orcid.org/0009-0002-2567-3343))

- Colin Walder <cwalder@ethz.ch>
  ([ORCID](https://orcid.org/0009-0006-0969-1954))

Other contributors:

- Global Health Engineering, ETH Zurich \[copyright holder\]
