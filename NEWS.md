annolite 0.0.1.9001 - 0.0.1.9002
================================

* The `annotate()` function will check whether the parent directory of a file stated via argument `file` exists and throws a warning if not (#6).
* The package *testthat*  is now a suggested package and there is a minimal testsuite.
* A new `is.annotationstable()` auxiliary function will check systematically that the input object is a valid `annotationstable` object.
* A new `as.annotationstable()` auxiliary function can be used to turn a `data.frame` into an `annotationstable` object.
* Tests on Travis CI will not require the (outdated) Trusty version of Linux.
* The `annolite()` function coerce the input argument `annotations` to a `annotationstable` object, running a validity check if it is a `data.frame` (#7).
* The *annolite* did not work as intended if argument `crosstalk`  was `FALSE` due to a misplaced JavaScript check whether the crosstalk library is present. The text is more robust now and the widget works as intended (#10).
* The JavaScript part of the package will handle situations correctly if the end position of a text selection is before the start position / annotation from right to left (#11).
* Deleting annotations did not work correctly, the annotation was removed even if user cancelled the action - fixed (#14).
* The example for the `annotate()` function still used a speech of Volker Kauder. Now it is the speech of Kofi Annan on the Millennium Declaration.
* Functionality to show tooltips has been restored. As comparedd to the previous pure CSS implementation, the new implementation of tooltips relies on the bootstrap JavaScript library (#15). A customn / self-made CSS definition has been removed from the package, as it is not necessary any more and as it provoked conflicts with bootstrap.


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

