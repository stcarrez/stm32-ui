#!/bin/sh

PIC=1
for i in $*; do
  echo -n "Converting $i..."
  convert -resize 470x270 $i tmp-gallery.gif
  echo -n " Ada-ification..."
  tools/bin/gif2ada Gallery.Picture$PIC tmp-gallery.gif > demos/gallery/gallery-picture$PIC.ads
  echo " Done"
  rm -f tmp-gallery.gif
  PIC=`expr $PIC + 1`
done
