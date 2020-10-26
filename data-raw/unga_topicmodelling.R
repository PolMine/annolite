library(annolite)
library(zen4R)
library(topicmodels)
library(polmineR) # at least v0.8.5.9006

unga_zenodo_doi <- "10.5281/zenodo.3831472"
zenodo_record <- ZenodoManager$new()$getRecordByDOI(doi = unga_zenodo_doi)
zenodo_files <- sapply(zenodo_record[["files"]], function(x) x[["links"]][["download"]])

lda_file <- zenodo_files[grepl("^lda_UNGA.*$", basename(zenodo_files))]

lda_tmp_local <- tempfile()
download.file(url = lda_file, destfile = lda_tmp_local)

unga_lda <- readRDS(lda_tmp_local)
topic_term_matrix <- topicmodels::get_terms(unga_lda, k = 50)

document_topics <- topicmodels::get_topics(unga_lda, k = 1)
mig_speeches <- sample(names(document_topics)[document_topics == 105], size = 25)

unga_speeches <- as.speeches("UNGA", s_attribute_date = "date", s_attribute_name = "speaker")
unga_speeches_mig <- unga_speeches[[mig_speeches]]

unga_migrationspeeches_fulltext <- lapply(
  seq_along(unga_speeches_mig),
  function(i) fulltexttable(unga_speeches_mig[[i]], name = mig_speeches[[i]])
)

unga_migrationspeeches_fulltext <- do.call(rbind, unga_migrationspeeches_fulltext)


# Create annotationstable

unga_speeches_mig_merged <- merge(unga_speeches_mig)
matches <- cpos(unga_speeches_mig_merged, query = topic_term_matrix[,105])

unga_migrationspeeches_anntationstable <- annotationstable(
  text = rep("", times = nrow(matches)),
  code = rep("MigrationTopic", times = nrow(matches)),
  color = rep("yellow", times = nrow(matches)),
  annotation = rep("", times = nrow(matches)),
  start = matches[,1],
  end = matches[,2]
)

save(
  unga_migrationspeeches_fulltext,
  unga_migrationspeeches_anntationstable,
  file = "~/Lab/github/annolite/data/unga_migrationspeeches.RData",
  compress = "xz"
)


