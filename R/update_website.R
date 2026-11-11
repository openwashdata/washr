#' Bring an existing _pkgdown.yml in line with the washr template
#'
#' @description
#' `update_website()` adds to an existing `_pkgdown.yml` what the washr
#' template has gained since the file was written, and refreshes what washr
#' owns: the footer with the washr version and the publisher sentence, the
#' link to the website of the organisation in the navbar, the funding and
#' the community blocks of the sidebar, the light switch of the site, and
#' the Open Graph image when the brand is installed. Everything else is kept as it is: the reference
#' index, hand edits, comments and the brand wiring of [use_brand()]. A
#' file that is current is left untouched (#145).
#'
#' The texts and links come from the `Config/washr/` fields in DESCRIPTION
#' that [update_description()] writes (`publisher`, `home`, `catalog`,
#' `community`, `funding`); a field set to `none` leaves its block out. The
#' footer names the washr version that last ran [update_description()],
#' which also refreshes that line on its own.
#'
#' Blocks written by hand are respected. A footer, a navbar or a sidebar
#' that already carries a component of the same name keeps it, and the
#' function adds only what is missing. The file is written only when the
#' result parses as YAML.
#'
#' The navbar of a washr site lists the light switch, and pkgdown shows it
#' only when the template says `light-switch: true`. `update_website()` adds
#' that line to a Bootstrap 5 site that lacks it, so readers can change to
#' the dark theme, where the dark logo of the brand is shown. A file that
#' already sets `light-switch`, also to `false`, keeps its value.
#'
#' @param build Logical. Rebuild the site with [pkgdown::build_site()] when
#'   the file changed? Defaults to `FALSE`.
#'
#' @returns Invisibly, the names of the blocks that changed (`"footer"`,
#'   `"navbar"`, `"sidebar"`, `"lightswitch"`, `"opengraph"`), or an empty vector when the
#'   file was current.
#'
#' @seealso Before: [setup_website()], which writes a new `_pkgdown.yml` from
#'   the template, and [use_brand()], which installs the brand this reads for
#'   the Open Graph image. Next: [check_publication_readiness()].
#'
#' @family publishing functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # After a washr update, bring the site configuration up to date
#' update_website()
#'
#' # The same, and rebuild the site
#' update_website(build = TRUE)
#' }
update_website <- function(build = FALSE) {
  local_session()
  configpath <- "_pkgdown.yml"
  if (!file.exists(configpath)) {
    cli::cli_abort(c(
      "No {.path {configpath}} exists.",
      "i" = "Run {.fun setup_website} first; it writes the file from the template."
    ))
  }
  original <- readLines(configpath, warn = FALSE)
  data <- pkgdown_template_data()
  unit <- yaml_indent_unit(original)
  lines <- original
  changed <- character(0)

  step <- function(name, result) {
    lines <<- result$lines
    if (isTRUE(result$changed)) changed <<- c(changed, name)
    for (note in result$notes) ui_info(note)
  }
  step("footer", pkgdown_update_footer(lines, data, unit))
  step("navbar", pkgdown_update_navbar(lines, data, unit))
  step("sidebar", pkgdown_update_sidebar(lines, data, unit))
  step("lightswitch", pkgdown_update_lightswitch(lines, unit))
  step("opengraph", pkgdown_update_opengraph(lines, brand_opengraph_image(), unit))

  if (identical(lines, original)) {
    ui_done("{.path {configpath}} is current; nothing to change.")
    return(invisible(character(0)))
  }
  parsed <- tryCatch(yaml::yaml.load(paste(lines, collapse = "\n")), error = function(e) NULL)
  if (is.null(parsed)) {
    cli::cli_abort(c(
      "The updated {.path {configpath}} would not parse as YAML, so nothing was written.",
      "i" = "The file uses a layout washr cannot edit line by line. Add the blocks by hand; the template is in {.path {system.file('templates', '_pkgdown.yml', package = 'washr')}}."
    ))
  }
  writeLines(lines, configpath)
  ui_done("{.path {configpath}} updated: {changed}.")
  if (isTRUE(build)) {
    pkgdown::build_site()
  } else {
    ui_todo("Rebuild the site with {.code pkgdown::build_site()} to apply the change.")
  }
  invisible(changed)
}

# The footer sentence that names washr, with the version that writes it.
washr_footer_line <- function(version = utils::packageVersion("washr")) {
  sprintf("Package built with [washr](https://openwashdata.github.io/washr/) %s.", version)
}

# The host of a URL as link text: openwashdata.org for https://openwashdata.org/.
url_host <- function(url) {
  sub("/.*$", "", sub("^[a-z]+://", "", url))
}

# A flow sequence as written in the template: [a, b, c].
yaml_flow <- function(items) {
  paste0("[", paste(items, collapse = ", "), "]")
}

# Refresh the washr version in the footer of _pkgdown.yml, when the file
# and the line exist. update_description() calls this when it records the
# version in DESCRIPTION, so the two never disagree. Returns TRUE when the
# line changed.
refresh_pkgdown_washr_line <- function(path = ".") {
  configpath <- file.path(path, "_pkgdown.yml")
  if (!file.exists(configpath)) return(invisible(FALSE))
  lines <- readLines(configpath, warn = FALSE)
  range <- yaml_block(lines, "footer")
  if (is.null(range)) return(invisible(FALSE))
  idx <- yaml_find(lines, range, "^\\s+washr:\\s")
  if (is.na(idx)) return(invisible(FALSE))
  indent <- sub("^(\\s+).*$", "\\1", lines[idx])
  new <- paste0(indent, "washr: ", yaml_scalar(washr_footer_line()))
  if (identical(lines[idx], new)) return(invisible(FALSE))
  lines[idx] <- new
  writeLines(lines, configpath)
  ui_done("Footer of {.path _pkgdown.yml} names washr {utils::packageVersion('washr')}.")
  invisible(TRUE)
}

# The Open Graph image of the installed brand: the social preview of the
# brand repository at the ref that use_brand() recorded. NULL when no brand
# is installed, or when the brand repository has no such file.
brand_opengraph_image <- function(file = ".", probe = TRUE) {
  if (!file.exists(file.path(file, "DESCRIPTION"))) return(NULL)
  repo <- pkg_config("brand-source", file)
  ref <- washr_config("brand", file = file)
  if (!is_set(repo) || is.null(ref) || !file.exists(file.path(file, "_brand.yml"))) return(NULL)
  image <- brand_social_preview(repo, ref, file.path(file, "_brand.yml"))
  if (isTRUE(probe) && !url_exists(image$src)) return(NULL)
  image
}

# The social preview of a brand repository at a ref, and its alt text from
# the brand's meta name.
brand_social_preview <- function(repo, ref, brand_file = "_brand.yml") {
  brand <- tryCatch(yaml::read_yaml(brand_file), error = function(e) NULL)
  name <- brand$meta$name
  if (is.null(name) || !nzchar(name)) name <- sub("/.*$", "", repo)
  list(
    src = paste0("https://raw.githubusercontent.com/", repo, "/", ref, "/assets/social-preview.png"),
    alt = paste0(name, ", social preview image")
  )
}

# TRUE when a URL can be downloaded. Used before a URL is written into a
# site configuration, so a brand without the file leaves no broken image.
url_exists <- function(url) {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  tryCatch(
    {
      utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
      TRUE
    },
    error = function(e) FALSE,
    warning = function(w) FALSE
  )
}

# Line edits of _pkgdown.yml ------------------------------------------------
#
# The file is edited as text, never rewritten through the yaml package: a
# rewrite drops the comments and folds long lines, which breaks the verbatim
# funding text that the review standard looks for (see use_brand()). The
# helpers below read the layout of the file (top level keys, the indent unit,
# child keys and list values) and insert lines in the same style. An
# `unchanged` result is a list with the lines as they were.

# The indent unit of the file: the indent of its first indented line.
yaml_indent_unit <- function(lines) {
  indented <- grep("^\\s+[^#[:space:]]", lines, value = TRUE)
  if (!length(indented)) return(2L)
  unit <- nchar(sub("^(\\s+).*$", "\\1", indented[1]))
  if (unit < 1) 2L else unit
}

# The top level keys as written, named by key, valued by line index.
yaml_top_keys <- function(lines) {
  idx <- grep("^[A-Za-z_][A-Za-z0-9_-]*:", lines)
  stats::setNames(idx, sub(":.*$", "", lines[idx]))
}

# The lines of a top level block: from the key line to the line before the
# next top level key, blank lines and comments included. NULL when absent.
yaml_block <- function(lines, key) {
  keys <- yaml_top_keys(lines)
  if (!key %in% names(keys)) return(NULL)
  start <- keys[[key]]
  after <- keys[keys > start]
  end <- if (length(after)) min(after) - 1L else length(lines)
  c(start, end)
}

# The lines of a child mapping or list: from its key line to the last line
# indented deeper than the key.
yaml_child_range <- function(lines, start) {
  indent <- yaml_indent_of(lines[start])
  end <- start
  i <- start + 1L
  while (i <= length(lines)) {
    if (!grepl("^\\s*(#.*)?$", lines[i])) {
      if (yaml_indent_of(lines[i]) <= indent) break
      end <- i
    }
    i <- i + 1L
  }
  c(start, end)
}

yaml_indent_of <- function(line) {
  nchar(sub("^(\\s*).*$", "\\1", line))
}

# The last line of a range that carries content (not blank, not a comment).
yaml_content_end <- function(lines, range) {
  idx <- seq(range[1], range[2])
  content <- idx[!grepl("^\\s*(#.*)?$", lines[idx])]
  if (length(content)) max(content) else range[1]
}

# The index of the first line in a range that matches a pattern, or NA.
yaml_find <- function(lines, range, pattern) {
  idx <- seq(range[1], range[2])
  hit <- idx[grepl(pattern, lines[idx])]
  if (length(hit)) hit[1] else NA_integer_
}

# The index of a child key written at an exact indent inside a range.
yaml_child <- function(lines, range, key, indent) {
  yaml_find(lines, range, paste0("^", strrep(" ", indent), key, ":"))
}

# The value written after `key:` on one line, trimmed; "" for a block value.
yaml_inline_value <- function(line) {
  value <- sub("^\\s*[^:]+:", "", line)
  trimws(sub("\\s+#.*$", "", value))
}

# Insert lines after a given line index.
yaml_insert_after <- function(lines, new, after) {
  append(lines, new, after = after)
}

# Insert a top level block before the first key of `before` that exists,
# separated by one blank line from the block above; else append it at the
# end of the file.
yaml_insert_block <- function(lines, block, before = character()) {
  keys <- yaml_top_keys(lines)
  target <- before[before %in% names(keys)]
  if (!length(target)) {
    return(c(lines, "", block))
  }
  start <- keys[[target[1]]]
  previous <- keys[keys < start]
  if (!length(previous)) {
    return(c(block, "", lines))
  }
  prev_end <- yaml_content_end(lines, c(max(previous), start - 1L))
  append(lines, c("", block), after = prev_end)
}

# Add an item to the list written at `idx`: a flow sequence (`key: [a, b]`),
# a scalar (`key: a`) or a block sequence on the following lines. `before`
# names items to insert ahead of, the first one present wins; `first` puts
# the item at the front; else the item goes last. Quotes around existing
# items are ignored in the comparison and kept in the file.
yaml_add_item <- function(lines, idx, item, before = NULL, first = FALSE) {
  unchanged <- list(lines = lines, changed = FALSE)
  bare <- function(x) gsub("^['\"]|['\"]$", "", trimws(x))
  place <- function(items) {
    if (first) return(c(item, items))
    anchor <- before[before %in% bare(items)]
    if (length(anchor)) return(append(items, item, after = match(anchor[1], bare(items)) - 1L))
    c(items, item)
  }
  line <- lines[idx]
  key_part <- sub("^(\\s*[^:]+:).*$", "\\1", line)
  value <- yaml_inline_value(line)
  if (grepl("^\\[.*\\]$", value)) {
    items <- trimws(strsplit(sub("^\\[(.*)\\]$", "\\1", value), ",")[[1]])
    items <- items[nzchar(items)]
    if (item %in% bare(items)) return(unchanged)
    lines[idx] <- paste0(key_part, " ", yaml_flow(place(items)))
    return(list(lines = lines, changed = TRUE))
  }
  if (nzchar(value)) {
    if (identical(bare(value), item)) return(unchanged)
    lines[idx] <- paste0(key_part, " ", yaml_flow(place(value)))
    return(list(lines = lines, changed = TRUE))
  }
  # The items of a block sequence: the `- ` lines after the key, at the
  # indent of the key (the style the yaml package writes, so the style of a
  # file use_brand() rewrote) or deeper, up to the first line that belongs
  # to a sibling or a parent. Blank lines and comments are passed over, the
  # continuation lines of an item are skipped.
  key_indent <- yaml_indent_of(line)
  entries <- integer(0)
  i <- idx + 1L
  while (i <= length(lines)) {
    if (!grepl("^\\s*(#.*)?$", lines[i])) {
      ind <- yaml_indent_of(lines[i])
      if (grepl("^\\s*- ", lines[i]) && ind >= key_indent) {
        entries <- c(entries, i)
      } else if (ind <= key_indent) {
        break
      }
    }
    i <- i + 1L
  }
  if (!length(entries)) {
    indent <- strrep(" ", key_indent + 2L)
    return(list(lines = append(lines, paste0(indent, "- ", item), after = idx), changed = TRUE))
  }
  items <- bare(sub("^\\s*- ", "", lines[entries]))
  if (item %in% items) return(unchanged)
  indent <- sub("^(\\s*).*$", "\\1", lines[entries[1]])
  anchor <- before[before %in% items]
  after <- if (first) {
    entries[1] - 1L
  } else if (length(anchor)) {
    entries[match(anchor[1], items)] - 1L
  } else {
    max(entries)
  }
  list(lines = append(lines, paste0(indent, "- ", item), after = after), changed = TRUE)
}

# The footer: the washr line is added or refreshed, the publisher sentence
# added when the organisation has one, and both named in the structure.
pkgdown_update_footer <- function(lines, data, unit = 2L) {
  i1 <- strrep(" ", unit)
  i2 <- strrep(" ", 2L * unit)
  range <- yaml_block(lines, "footer")
  if (is.null(range)) {
    block <- c(
      "footer:",
      paste0(i1, "structure:"),
      paste0(i2, "left: ", data$footer_left),
      paste0(i2, "right: ", data$footer_right),
      paste0(i1, "components:"),
      if (data$has_publisher) paste0(i2, "publisher: ", data$publisher),
      paste0(i2, "washr: ", data$washr_line)
    )
    return(list(lines = yaml_insert_block(lines, block, before = "reference"), changed = TRUE))
  }
  changed <- FALSE
  components <- function() yaml_child(lines, yaml_block(lines, "footer"), "components", unit)
  if (is.na(components())) {
    lines <- yaml_insert_after(lines, paste0(i1, "components:"), yaml_content_end(lines, yaml_block(lines, "footer")))
    changed <- TRUE
  }
  washr_line <- paste0(i2, "washr: ", data$washr_line)
  idx <- yaml_find(lines, yaml_block(lines, "footer"), "^\\s+washr:\\s")
  if (is.na(idx)) {
    lines <- yaml_insert_after(lines, washr_line, components())
    changed <- TRUE
  } else if (!identical(lines[idx], washr_line)) {
    lines[idx] <- washr_line
    changed <- TRUE
  }
  if (data$has_publisher && is.na(yaml_find(lines, yaml_block(lines, "footer"), "^\\s+publisher:\\s"))) {
    lines <- yaml_insert_after(lines, paste0(i2, "publisher: ", data$publisher), components())
    changed <- TRUE
  }
  structure <- yaml_child(lines, yaml_block(lines, "footer"), "structure", unit)
  if (is.na(structure)) {
    lines <- yaml_insert_after(lines, c(paste0(i1, "structure:"),
                                        paste0(i2, "left: ", data$footer_left),
                                        paste0(i2, "right: ", data$footer_right)),
                               yaml_block(lines, "footer")[1])
    return(list(lines = lines, changed = TRUE))
  }
  side <- function(name) yaml_child(lines, yaml_child_range(lines, structure), name, 2L * unit)
  if (is.na(side("right"))) {
    lines <- yaml_insert_after(lines, paste0(i2, "right: ", data$footer_right), structure)
    changed <- TRUE
  } else {
    res <- yaml_add_item(lines, side("right"), "washr", first = TRUE)
    lines <- res$lines
    changed <- changed || res$changed
  }
  if (data$has_publisher) {
    if (is.na(side("left"))) {
      lines <- yaml_insert_after(lines, paste0(i2, "left: ", data$footer_left), structure)
      changed <- TRUE
    } else {
      res <- yaml_add_item(lines, side("left"), "publisher")
      lines <- res$lines
      changed <- changed || res$changed
    }
  }
  list(lines = lines, changed = changed)
}

# The navbar: a `home` component that links the website of the organisation,
# placed before the GitHub icon. A navbar that already has a `home`
# component is left alone.
pkgdown_update_navbar <- function(lines, data, unit = 2L) {
  unchanged <- list(lines = lines, changed = FALSE)
  if (!isTRUE(data$has_home)) return(unchanged)
  i1 <- strrep(" ", unit)
  i2 <- strrep(" ", 2L * unit)
  i3 <- strrep(" ", 3L * unit)
  component <- c(
    paste0(i2, "home:"),
    paste0(i3, "text: ", data$home_text),
    paste0(i3, "href: ", data$home),
    paste0(i3, "aria-label: ", yaml_scalar(data$home_label))
  )
  range <- yaml_block(lines, "navbar")
  if (is.null(range)) {
    block <- c("navbar:",
               paste0(i1, "structure:"),
               paste0(i2, "right: ", data$navbar_right),
               paste0(i1, "components:"),
               component)
    return(list(lines = yaml_insert_block(lines, block, before = c("home", "authors", "footer", "reference")),
                changed = TRUE))
  }
  if (!is.na(yaml_child(lines, range, "home", 2L * unit))) {
    return(c(unchanged, notes = "The navbar already has a home component; it is kept as it is."))
  }
  components <- yaml_child(lines, range, "components", unit)
  if (is.na(components)) {
    lines <- yaml_insert_after(lines, paste0(i1, "components:"), yaml_content_end(lines, range))
    components <- yaml_child(lines, yaml_block(lines, "navbar"), "components", unit)
  }
  lines <- yaml_insert_after(lines, component, components)
  structure <- yaml_child(lines, yaml_block(lines, "navbar"), "structure", unit)
  if (is.na(structure)) {
    lines <- yaml_insert_after(lines, c(paste0(i1, "structure:"), paste0(i2, "right: ", data$navbar_right)),
                               yaml_block(lines, "navbar")[1])
    return(list(lines = lines, changed = TRUE))
  }
  right <- yaml_child(lines, yaml_child_range(lines, structure), "right", 2L * unit)
  if (is.na(right)) {
    lines <- yaml_insert_after(lines, paste0(i2, "right: ", data$navbar_right), structure)
  } else {
    lines <- yaml_add_item(lines, right, "home", before = c("github", "lightswitch"))$lines
  }
  list(lines = lines, changed = TRUE)
}

# The sidebar of the home page: the funding block (`custom`) and the
# community block, each added when the organisation has the text and the
# file lacks the component, and both named in the structure. A sidebar
# switched off or replaced by an HTML file is left alone.
pkgdown_update_sidebar <- function(lines, data, unit = 2L) {
  unchanged <- list(lines = lines, changed = FALSE)
  wanted <- list()
  if (isTRUE(data$has_funding)) wanted$custom <- c("Funding", data$funding)
  if (isTRUE(data$has_community)) wanted$community <- c(data$community_title, data$community)
  if (!length(wanted)) return(unchanged)
  i1 <- strrep(" ", unit)
  i2 <- strrep(" ", 2L * unit)
  i3 <- strrep(" ", 3L * unit)
  i4 <- strrep(" ", 4L * unit)
  component_lines <- function(name) {
    c(paste0(i3, name, ":"),
      paste0(i4, "title: ", yaml_scalar(wanted[[name]][1])),
      paste0(i4, "text: ", wanted[[name]][2]))
  }
  structure_line <- paste0(i2, "structure: ", data$sidebar_structure)
  range <- yaml_block(lines, "home")
  if (is.null(range)) {
    block <- c("home:", paste0(i1, "sidebar:"), structure_line, paste0(i2, "components:"),
               unlist(lapply(names(wanted), component_lines), use.names = FALSE))
    return(list(lines = yaml_insert_block(lines, block, before = c("authors", "footer", "reference")),
                changed = TRUE))
  }
  sidebar <- yaml_child(lines, range, "sidebar", unit)
  if (is.na(sidebar)) {
    block <- c(paste0(i1, "sidebar:"), structure_line, paste0(i2, "components:"),
               unlist(lapply(names(wanted), component_lines), use.names = FALSE))
    lines <- yaml_insert_after(lines, block, yaml_content_end(lines, range))
    return(list(lines = lines, changed = TRUE))
  }
  value <- yaml_inline_value(lines[sidebar])
  srange <- yaml_child_range(lines, sidebar)
  if (identical(tolower(value), "false") || !is.na(yaml_child(lines, srange, "html", 2L * unit))) {
    return(c(unchanged, notes = "The sidebar is switched off or comes from an HTML file; it is kept as it is."))
  }
  changed <- FALSE
  sidebar_range <- function() yaml_child_range(lines, yaml_child(lines, yaml_block(lines, "home"), "sidebar", unit))
  components <- yaml_child(lines, srange, "components", 2L * unit)
  if (is.na(components)) {
    lines <- yaml_insert_after(lines, paste0(i2, "components:"), yaml_content_end(lines, srange))
    components <- yaml_child(lines, sidebar_range(), "components", 2L * unit)
    changed <- TRUE
  }
  added <- character(0)
  for (name in names(wanted)) {
    crange <- yaml_child_range(lines, components)
    if (is.na(yaml_child(lines, crange, name, 3L * unit))) {
      lines <- yaml_insert_after(lines, component_lines(name), yaml_content_end(lines, crange))
      added <- c(added, name)
      changed <- TRUE
    }
  }
  structure <- yaml_child(lines, sidebar_range(), "structure", 2L * unit)
  if (is.na(structure)) {
    lines <- yaml_insert_after(lines, structure_line, yaml_child(lines, yaml_block(lines, "home"), "sidebar", unit))
    return(list(lines = lines, changed = TRUE))
  }
  for (name in names(wanted)) {
    res <- yaml_add_item(lines, structure, name, before = if (identical(name, "custom")) "community")
    lines <- res$lines
    changed <- changed || res$changed
  }
  list(lines = lines, changed = changed)
}

# The light switch under template: pkgdown lists `lightswitch` in the navbar
# by default and shows it only with `light-switch: true`, so without the
# line the dark theme, and the dark logo of the brand, are never reached.
# Added after the bootstrap line of a Bootstrap 5 site; a file that sets
# the key, also to false, keeps its value.
pkgdown_update_lightswitch <- function(lines, unit = 2L) {
  unchanged <- list(lines = lines, changed = FALSE)
  range <- yaml_block(lines, "template")
  if (is.null(range) || nzchar(yaml_inline_value(lines[range[1]]))) return(unchanged)
  if (!is.na(yaml_child(lines, range, "light-switch", unit))) return(unchanged)
  bootstrap <- yaml_child(lines, range, "bootstrap", unit)
  if (is.na(bootstrap) || !identical(yaml_inline_value(lines[bootstrap]), "5")) {
    return(c(unchanged, notes = "The site does not use Bootstrap 5, so it gets no light switch."))
  }
  lines <- yaml_insert_after(lines, paste0(strrep(" ", unit), "light-switch: true"), bootstrap)
  list(lines = lines, changed = TRUE)
}

# The Open Graph image under template: added when missing; an image that
# points at the brand repository follows the installed ref; any other image
# is someone's choice and stays.
pkgdown_update_opengraph <- function(lines, image, unit = 2L) {
  unchanged <- list(lines = lines, changed = FALSE)
  if (is.null(image)) return(unchanged)
  i1 <- strrep(" ", unit)
  i2 <- strrep(" ", 2L * unit)
  i3 <- strrep(" ", 3L * unit)
  src_line <- paste0(i3, "src: ", image$src)
  alt_line <- paste0(i3, "alt: ", yaml_scalar(image$alt))
  range <- yaml_block(lines, "template")
  if (is.null(range)) {
    block <- c("template:", paste0(i1, "opengraph:"), paste0(i2, "image:"), src_line, alt_line)
    return(list(lines = yaml_insert_block(lines, block, before = c("navbar", "home", "authors", "footer", "reference")),
                changed = TRUE))
  }
  if (nzchar(yaml_inline_value(lines[range[1]]))) return(unchanged)
  opengraph <- yaml_child(lines, range, "opengraph", unit)
  if (is.na(opengraph)) {
    lines <- yaml_insert_after(lines, c(paste0(i1, "opengraph:"), paste0(i2, "image:"), src_line, alt_line),
                               yaml_content_end(lines, range))
    return(list(lines = lines, changed = TRUE))
  }
  orange <- yaml_child_range(lines, opengraph)
  img <- yaml_child(lines, orange, "image", 2L * unit)
  if (is.na(img)) {
    lines <- yaml_insert_after(lines, c(paste0(i2, "image:"), src_line, alt_line), opengraph)
    return(list(lines = lines, changed = TRUE))
  }
  irange <- yaml_child_range(lines, img)
  src <- yaml_child(lines, irange, "src", 3L * unit)
  if (is.na(src)) {
    lines <- yaml_insert_after(lines, c(src_line, alt_line), img)
    return(list(lines = lines, changed = TRUE))
  }
  current <- yaml_inline_value(lines[src])
  brand_repo <- sub("^https://raw\\.githubusercontent\\.com/([^/]+/[^/]+)/.*$", "\\1", image$src)
  ours <- grepl(paste0("^https://raw\\.githubusercontent\\.com/", brand_repo, "/"), current)
  if (!ours || identical(current, image$src)) return(unchanged)
  lines[src] <- src_line
  list(lines = lines, changed = TRUE)
}
