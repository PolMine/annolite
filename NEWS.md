annolite 0.0.0.9005
===================

* An error when running R CMD check resulting from a limitation of polmineR to be loaded multiple times is resolved by commenting out the example of `as.fulltext`.
* Mixed up special characters are displayed correctly now (#2).
* The `as.fulltextdata()` function has been turned into a (S3) method, it is defined for plpr_partition objects and `subcorpus` objects.
* In the dialogue opened for annotation, the first radio button is checked by default (not the last) (#3)
* The `data.frame` returned by the annotation widget now reports the code in the column "code". Previously, the colour of the code had been reported.
