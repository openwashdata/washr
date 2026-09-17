# Evaluation: the lt package for README tables and the pkgdown index

Owner: Lars Schöbitz. Written 2026-09-04. Trial run on fslogisticskampala 1.0.0.

## Question

Should the washr README template render its tables with
[lt](https://github.com/yihui/lt) (Yihui Xie, "lightweight tables",
version 0.4.2 at the time of writing) instead of gt and kableExtra? The
README is the source of the pkgdown home page, so the question covers both
README.md on GitHub and `index.html` on the package site.

## What lt is

lt is a small grammar of tables in the spirit of gt: title, spanners, row
groups, footnotes, number and date formatting, column widths, custom CSS.
It depends on xfun only (six recursive dependencies against 49 for
kableExtra on the trial machine). It targets HTML only.

The design choice that decides this evaluation: an lt table is not HTML.
`lt()` records the data plus a list of operations; rendering emits a
`<script>` block with the JSON spec and, once per page, the runtime
(`lt.css`, 1.5 KB, and `lt.js`, 26 KB unminified) inlined as `<style>` and
`<script>`. A browser builds the `<table>` when the page loads. Two escape
hatches produce a static `<table>`: `lt_export(x, "file.html")` and the
option `lt.lt_static`, which makes the knitr print method bake the table
through Node.js or a headless Chromium at knit time.

## Trial

`trial-fslogisticskampala.Rmd` next to this file renders the fslogisticskampala
preview table (`head(trips, 3)`), the variable table from the dictionary,
and the download table in four variants: the current template (kable plus
kableExtra), lt in its default JavaScript form, lt baked to a static table,
and plain `knitr::kable()`. It was rendered with `github_document`, the
output format of the README template, on R 4.3.3, knitr 1.45, rmarkdown
2.25, pandoc 3.1.3, xfun 0.60.1 and lt 0.4.2 from GitHub. The resulting
README-style markdown was then converted to HTML the way pkgdown converts
README.md (pandoc, markdown to html5) and opened in headless Chromium to see
what a visitor gets.

## Findings

1. **The default lt output shows no table on the pkgdown index.** The
   `github_document` format writes README.md with pandoc's gfm writer, which
   replaces every blank line inside a raw HTML block with the entity
   `&#10;` so the block stays contiguous. The inlined `lt.js` has blank
   lines; after the round trip it contains 52 `&#10;` sequences, which is a
   JavaScript syntax error (`node --check` fails on line 8). The runtime
   never loads, so none of the tables on the page is built. The same
   markdown rendered straight to `html_document` (no round trip through
   README.md) builds all tables, so lt itself works; it is the
   README.Rmd → README.md → pkgdown pipeline that breaks it. gt's
   `as_raw_html()` survives the same round trip because it emits a plain
   `<table>` with inline styles.

2. **The default lt output shows no table on GitHub either.** GitHub strips
   `<script>` and `<style>` from rendered markdown, so a JavaScript-built
   table has nothing to fall back to. The current gt and kableExtra
   output degrades to unstyled but complete HTML tables there (GitHub also
   removes `style` attributes, which is why the 200 px scroll box of the
   variable table does not scroll on GitHub today).

3. **Baking works, at the price of a system dependency.** With
   `options(lt.lt_static = list(method = "node", css = FALSE, fragment = TRUE))`
   the knitr print method writes a semantic `<table class="lt-table">`
   (about 0.9 KB for the three-row preview against roughly 12 KB for the
   equivalent gt table with inline styles). It renders on GitHub, on the
   pkgdown index, and in the markdown variants pkgdown 2.2 writes next to
   each page. Raw HTML columns work, so the download table can carry real
   links. The bake needs Node.js or a Chromium browser on the machine that
   runs `devtools::build_readme()`. fslogisticskampala already needs Chromium
   for its webshot2 map, but the washr template is meant for student
   contributors, and a README that fails to build without Node.js or Chrome
   is a new support burden. Without the `css = FALSE` setting the baked
   output also carries lt's stylesheet, which the gfm round trip mangles the
   same way (six `&#10;` entities inside `<style>`).

4. **Auto-formatting alters data values in the preview.** `lt()` rounds
   numeric columns to about four significant digits by default: latitude
   0.358437 became 0.3584 and longitude 32.550365 became 32.55. The original
   value is kept only in a `title` tooltip, which GitHub removes. A data
   package preview must show the stored values, so every call needs
   `lt(auto_format = FALSE)`. `auto_label` likewise rewrites `variable_name`
   as "variable name"; the dictionary table needs `auto_label = FALSE`.

5. **Date columns need per-column handling.** xfun serialises Date columns
   as JavaScript `new Date(...)` values and lt prints them with the browser's
   default string unless `lt_date()` is applied to the column: the trial
   showed `Mon Mar 30 2015 00:00:00 GMT+0000 (Coordinated Universal Time)`
   for `2015-03-30`. A generic template does not know which columns are
   dates, so it would have to convert them to character first.

6. **Nothing in the README needs a grammar of tables.** The three tables
   are a three-row preview, a three-column dictionary, and a link table. None
   uses spanners, footnotes, row groups, or formatting. `knitr::kable()`
   produces pipe tables that render everywhere (GitHub, pkgdown, pkgdown's
   markdown and `llms.txt` variants, the site search index) with no extra
   dependency, and it is already what the template uses for the download
   table.

## Recommendation

Do not adopt lt for the README template or the pkgdown index. Its runtime
model is at odds with a pipeline whose canonical artefact is a markdown file
consumed by GitHub and pkgdown, and the static bake adds a system dependency
to `build_readme()` for tables that need none of lt's features.

lt remains a reasonable choice inside articles under `vignettes/articles/`,
which pkgdown renders directly to HTML (no gfm round trip) and where a
lighter alternative to gt for a formatted table may be welcome. It is not
part of any washr function and does not need to be.

For the template itself, the trial points to a separate change worth a
follow-up: replace `gt::as_raw_html()` and `kableExtra::scroll_box()` with
`knitr::kable()`, which removes gt and kableExtra from the packages a
contributor has to install, shrinks README.md (the fslogisticskampala README
is 36 KB, most of it gt inline styles), and gives the same table on GitHub
and on the site. A long variable table can be wrapped in
`<details><summary>` markup, which GitHub and pkgdown both render, instead
of a scroll box that only works on the site.

## Reproducing the trial

```r
# in the root of a data package that has data/, data-raw/dictionary.csv
# and inst/extdata/; needs lt (remotes::install_github("yihui/lt")) and
# Node.js on the PATH for the baked variant
rmarkdown::render("trial-fslogisticskampala.Rmd")
```

Convert the result as pkgdown would and open it in a browser:

```sh
pandoc trial-fslogisticskampala.md -f markdown+gfm_auto_identifiers-yaml_metadata_block \
  -t html5 --standalone -o trial.html
```
