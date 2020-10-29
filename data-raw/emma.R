library(janeaustenr)
library(tokenizers)

emma_chapters <- split(
  emma,
  cut(1L:length(emma), c(1L, grep("^CHAPTER.*$", emma), length(emma)), right = FALSE)
)
emma_chapters[[1]] <- NULL


emma_chapters_tokenized <- lapply(
  seq_along(emma_chapters),
  function(i){
    chapter <- emma_chapters[[i]]
    breaks <- cut(1L:length(chapter), unique(c(1, grep("^\\s*$", chapter), length(chapter))))
    paras <- lapply(split(chapter, f = breaks), paste, collapse = " ")
    for (j in rev(which(sapply(paras, nchar) == 0L))) paras[[j]] <- NULL
    tokenizers::tokenize_words(paras, lowercase = FALSE, strip_punct = FALSE)
  }
)

emma_chapters_tokenized <- emma_chapters_tokenized[1:5]

save(
  emma_chapters_tokenized,
  file = "~/Lab/github/annolite/data/emma.RData",
  compress = "bzip2"
)

