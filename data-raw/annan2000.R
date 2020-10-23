library(polmineR)
library(annolite)

p <- partition("UNGA", date = "2000-04-03", speaker = "The Secretary-General", regex = TRUE)
f <- fulltextlist(p)
f2 <- lapply(f, function(x){x[[3]] <- x[[3]][c(-1, -nrow(x[[3]])),]; x})
secretary_general_2000 <- fulltextlist(f2)

save(secretary_general_2000, file = "~/Lab/github/annolite/data/sg.RData")
