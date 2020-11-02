annolite 0.0.1.9001
===================

* The `annotate()` function will check whether the parent directory of a file stated via argument `file` exists and throws a warning if not (#6).
* The package *testthat*  is now a suggested package and there is a minimal testsuite.


annolite 0.0.1
==============

* An error when running R CMD check resulting from a limitation of polmineR to be loaded multiple times is resolved by commenting out the example of `as.fulltext`.
* Mixed up special characters are displayed correctly now (#2).
* The `as.fulltextdata()` function has been turned into a (S3) method, it is defined for plpr_partition objects and `subcorpus` objects.
* In the dialogue opened for annotation, the first radio button is checked by default (not the last) (#3)
* The `data.frame` returned by the annotation widget now reports the code in the column "code". Previously, the colour of the code had been reported.
* Columns "id_left" and "id_right" in the annotations table have been renamed and are "start" and "end" now.
* The bug that occurred when cancelling the annotation dialogue is resolved.
* Including whitespace on the left or right of an annotation provoked a creash - resolved (#4).
* The R function `dialog_default_callback()` that defined a default callback function for the bootbox dialogue has been removed. The default JavaScript callback function it defined had grown so complicated that it is unlikely that modificiations "on the fly" are possible and likely.
* The htmlwidget included in the package has been renamed as "annotator" (previously: "fulltext").
* The `as.fulltextdata()` has been renamed as `as.annotatordata`.
* Calling the annotator widget is faster, resulting from an improved JavaScript implemention.
* Argument `headline` of the `as.annotatordata()` method has now default value `NULL`, it is not necessary to provide argument.
* The README was totally outdated and the bulk of the content has been removed.
* Methods `as.fulltexttable()`, R6 Class `FulltextData` and the `fulltext()` function have been integrated into annolite package from fulltext package.
* The CSS file markdown7.css included in the fulltext package supersedes the equally-named file in annolite, assuming that the fullext package has seen relevant updates.

