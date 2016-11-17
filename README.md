# Image Tiler

Simple script that takes a huge image and tiles it so it can be used in common mapping frameworks.

[Demo](https://jleppert.github.io/image-tiler/leaflet.html)

  usage: ./tile.sh <input> <width> <height> <min zoom> <max zoom> <tileSize> 

ex: 
  
  ./tile.sh huge.jpg 8408 8337 18 20 256

This generates tiles of the image huge.jpg (8408x8337) for zoom levels 18-20 with a tile size of 256x256.
