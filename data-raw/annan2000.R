library(polmineR)
library(annolite)
use("UNGA")

P <- partition("UNGA", date = "2000-04-03", who = "The Secretary-General", regex = TRUE)

as.fulltextdata(P)