library(polmineR)
library(annolite)

ftab <- corpus("UNGA") %>%
  subset(date == "2000-04-03") %>%
  subset(speaker == "The Secretary-General") %>% 
  fulltexttable()
ftab[["tokenstream"]] <- lapply(ftab[["tokenstream"]], function(x)x[c(-1, -nrow(x)),])

secretary_general_2000 <- ftab

save(
  secretary_general_2000,
  file = "~/Lab/github/annolite/data/sg.RData",
  compress = "xz"
)
