# Bring the dictionary in line with the tidy data

`update_dictionary()` reads the data objects in `data/` again and
updates `data-raw/dictionary.csv` to match them. Run it after the data
changed: a variable was added, removed or renamed, its type changed, or
a data object was added or removed.

What you wrote in the dictionary is kept. Rows are matched on
`file_name` and `variable_name`, and a matched row keeps its description
and the value of every other column, including columns you added
yourself, such as `unit` or `allowed_values`. Only `variable_type` is
refreshed from the data. A new variable gets a row with empty cells to
fill in. The row of a variable that no longer exists is removed, and the
function names it. A renamed variable or data object cannot be told from
one removed and one added, so what you wrote in the removed rows is
printed for you to copy into the new rows.

The columns keep the order they have in the file. The rows follow the
data: data objects in alphabetical order, variables in the order of the
data object. When nothing differs, the file is left untouched, so the
function is safe to run again.

## Usage

``` r
update_dictionary()
```

## Value

The path of the dictionary file, invisibly. Error if there is no
dictionary yet, no tidy data, or the dictionary lacks the `file_name` or
`variable_name` column.

## See also

Before:
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md),
which writes the dictionary the first time. Next:
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md),
which regenerates the variable table of the documentation from the
dictionary.

Other setup functions:
[`setup_ci()`](https://openwashdata.github.io/washr/reference/setup_ci.md),
[`setup_dictionary()`](https://openwashdata.github.io/washr/reference/setup_dictionary.md),
[`setup_rawdata()`](https://openwashdata.github.io/washr/reference/setup_rawdata.md),
[`setup_roxygen()`](https://openwashdata.github.io/washr/reference/setup_roxygen.md)

## Examples

``` r
if (FALSE) { # \dontrun{
setup_dictionary()
# Later, after data_processing.R exported changed data
update_dictionary()
setup_roxygen()
} # }
```
