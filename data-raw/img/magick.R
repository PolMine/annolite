library(purrr)
library(magick)


files <- sprintf(
  "/Users/andreasblaette/Lab/github/annolite/data-raw/img/screenshot%d.png",
  1:13
)
  
images <- map(files, image_read)
images <- lapply(images, function(img) image_scale(img, "800x500!"))
images <- image_join(images)
animation <- image_animate(images, fps = 0.5)
image_write(animation, path = "~/Lab/github/annolite/vignettes/img/demo.gif")
