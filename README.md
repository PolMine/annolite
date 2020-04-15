
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis-CI Build
Status](https://api.travis-ci.org/PolMine/annolite.svg?branch=dev)](https://travis-ci.org/PolMine/annolite)
[![codecov](https://codecov.io/gh/PolMine/annolite/branch/dev/graph/badge.svg)](https://codecov.io/gh/PolMine/annolite/branch/dev)
<!-- badges: end -->

## Purpose

The purpose of the ´annolite´-package is to offer a htmlwidget to
reconstruct a formatted fulltext output from input data of tokenized
text. To provide the basis for an annotation tool that can detect the
corpus positions of annotations, each token is supplemented with
(invisible) additional information, such as corpus positions.

## Getting Started

``` r
library(janeaustenr)
library(tokenizers)
library(annolite)
```

## From tidytext to fulltext

``` r
emma_txt <- janeaustenr::emma[grep("^CHAPTER\\s+.*?$", janeaustenr::emma)[1]:length(janeaustenr::emma)]
chapter_beginnings <- grep("^CHAPTER\\s+.*?$", emma_txt)
chapters <- split(
  emma_txt,
  cut(
    1L:length(emma_txt),
    c(chapter_beginnings, length(emma_txt)),
    include.lowest = TRUE, right = FALSE
  )
)

reconstruct_paragraphs <- function(x){
  paras <- split(
    x, 
    cut(
      1L:length(x),
      unique(c(1L, grep("^\\s*$", x), length(x))),
      include.lowest = TRUE, right = FALSE
    )
  )
  paras <- lapply(paras, function(x) x[x != ""])
  for (i in rev(which(lapply(paras, length) == 0))) paras[[i]] <- NULL
  sapply(paras, function(p) paste(p, collapse = " "))
}

chs <- lapply(chapters, reconstruct_paragraphs)

as_paragraphdata <- function(x){
  paras_tok <- tokenizers::tokenize_words(x, lowercase = FALSE, strip_punct = FALSE)
  df1 <- lapply(
    1:length(paras_tok),
    function(i) data.frame(token = paras_tok[[i]], para = i)
  )
  df2 <- do.call(rbind, df1)
  df2[["cpos"]] <- 1L:nrow(df2)
  para_list <- split(df2, f = df2[["para"]])
  
  lapply(
    para_list,
    function(x) list(element = "p", tokenstream = x[, c("cpos", "token")])
  )
}

ch1 <- as_paragraphdata(chs[[1]])
ch1[[1]][["element"]] <- "h3"
ch1 <- c(
  list(list(
    element = "h2",
    tokenstream = data.frame(token = c("Jane", "Austen", "-", "Emma"), cpos = 10001L:10004L)
    )),
  ch1
)
```

``` r
fulltext(ch1, dialog = FALSE, box = TRUE, width = 650)
```

## Initialization

We introduce the fulltext package by example. In addition to the
fulltext package, we need the polmineR package which includes the
GERMAPARLMINI corpus.

``` r
library(annolite)
library(polmineR)
use("polmineR")
```

    ## ... activating corpus: GERMAPARLMINI

    ## ... activating corpus: REUTERS

## The speech to reconstruct

The example aims at outputting one particular speech. We take a speech
held by Voker Kauder in the German
Bundestag.

``` r
P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
```

    ## ... get encoding: latin1

    ## ... get cpos and strucs

## Input data for the widget

The data that is passed to the JavaScript that generates the output.
Expected to be a list of lists that provide data on sections of text.
Each of the sub-lists is to be a named list of a character vector with
the HTML element the section will be wrapped into, and a `data.frame`
(or a list) with a column “token”, and a column “cpos”.

``` r
D <- as.fulltextdata(P, headline = "Volker Kauder (CDU)")
```

## Adding a headline

## Getting the output

``` r
fulltext(D, dialog = FALSE, box = TRUE, width = 650)
```

## Perspectives

Enjoy\!
