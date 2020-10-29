library(polmineR)
library(annolite)

secretary_general_2000_speech <- corpus("UNGA") %>%
  subset(date == "2000-04-03") %>%
  subset(speaker == "The Secretary-General") %>% 
  fulltexttable()

secretary_general_2000_speech[["tokenstream"]] <- lapply(
  secretary_general_2000_speech[["tokenstream"]],
  function(x) x[c(-1, -nrow(x)),]
)


secretary_general_2000_annotations <- annotate(
  secretary_general_2000_speech,
  buttons = list(
    organisation = "yellow",
    document = "lightgreen",
    date = "lightblue",
    issue = "lightgreen",
    geolocation = "red"
  )
)

save(
  secretary_general_2000_speech,
  secretary_general_2000_annotations,
  file = "~/Lab/github/annolite/data/sg.RData",
  compress = "xz"
)
