# Values that differ between publishing groups live in DESCRIPTION as
# Config/washr/<key> fields (#81), so a group other than openwashdata changes
# them by editing DESCRIPTION and no function carries its own copy.
# washr_config() is the one reader of these fields. It returns the value of
# Config/washr/<key>, or `default` when the field is absent or empty. `file`
# is a package root or the path of a DESCRIPTION file.
washr_config <- function(key, default = NULL, file = ".") {
  value <- desc::desc_get_field(paste0("Config/washr/", key), default = "",
                                file = file)
  value <- trimws(value)
  if (identical(value, "")) default else value
}
