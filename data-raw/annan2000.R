library(polmineR)
library(annolite)

secretary_general_2000 <- corpus("UNGA") %>%
  subset(date == "2000-04-03") %>%
  subset(speaker == "The Secretary-General") %>% 
  fulltexttable()

secretary_general_2000[["tokenstream"]] <- lapply(
  secretary_general_2000[["tokenstream"]],
  function(x) x[c(-1, -nrow(x)),]
)

save(
  secretary_general_2000,
  file = "~/Lab/github/annolite/data/sg.RData",
  compress = "xz"
)

if (interactive()){
  annotate(
    secretary_general_2000,
    buttons = list(
      organisation = "yellow",
      document = "lightgreen",
      date = "lightblue",
      issue = "lightgreen",
      geolocation = "red"
    )
  )
}
