#!/usr/bin/env bash
# this script takes a huge image and creates a tiled map at various zoom levels
# usage: ./tile.sh <input> <width> <height> <min zoom> <max zoom> 
# ex: ./tile.sh huge.jpg 8408 8337 18 20 
inputFile=$1
width=$2
height=$3
minZoom=$4
maxZoom=$5
tileSize=256

levels=$(( $maxZoom - $minZoom ))
echo $levels
for zoom in $(seq 0 $levels); do
  currentZoom=$(( $maxZoom - $zoom ))
  echo "Creating map for zoom level $currentZoom..."
  mkdir $currentZoom
  cd $currentZoom
  scale=$(( 1 << ($maxZoom - $currentZoom) ))
  bcCmd="bc -l <<< '(1 / $scale)*100'"
  bcScale=$(eval $bcCmd)
  scaledOutput=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32)

  scaleCmd="convert ../${inputFile} -scale ${bcScale}% ${scaledOutput}.jpg"
  echo "Resizing image for this zoom level.."
  eval $scaleCmd
  echo $bcScale

  scaledWidth=$(printf "%.0f" $(eval "bc  <<< 'scale=2; ($bcScale / 100) * $width'"))
  scaledHeight=$(printf "%.0f" $(eval "bc <<< 'scale=2; ($bcScale / 100) * $height'"))

  echo "-----"
  echo $scaledWidth
  echo $scaledHeight
  echo "-----"

  convertCmd="convert ${scaledOutput}.jpg -crop ${tileSize}x${tileSize}! -gravity NorthWest -extent ${tileSize}x${tileSize} -transparent white tiles_%d.png"
  echo "Creating tiles..."
  eval $convertCmd

  tileRegex="tiles_([0-9]+).png"
  for f in *.png
  do
    if [[ $f =~ $tileRegex ]]; then
      index="${BASH_REMATCH[1]}"
      tileWidth=$(echo "$scaledWidth $tileSize" | awk '{print int( ($1/$2) + 1 )}')
      x=$(( $index % $tileWidth ))
      y=$(( $index / $tileWidth ))
      mvCmd="mv $f map_${x}_${y}.png"
      eval $mvCmd
    fi 
  done

  echo "Done creating map for zoom level $currentZoom."

  cd ../
done
