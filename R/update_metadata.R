
update_metadata <- function(){
  update_biblio()
  print("-------------------------------------------------------------------------")
  update_access()
  cat("\n")
  print("-------------------------------------------------------------------------")
  update_attributes()
}
