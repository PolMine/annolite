.adjust_whitespace <- function(x){
  x[["whitespace"]] <- " "
  whitespace <- grep("^[\\.;,:!?\\)\\(]$", x[["token"]], perl = TRUE)
  if (length(whitespace) > 0L) x[whitespace, "whitespace"] <- ""
  x[1,"whitespace"] <- ""
  x
  
}
