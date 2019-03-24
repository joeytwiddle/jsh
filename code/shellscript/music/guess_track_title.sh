#!/bin/sh

echo "Don't use me!  Use guess_mp3_meta instead."
exit 1

split () {
  betweenthe "$@"
}

join () {
  delimiter="$*"
  sed "s$${delimiter}" | tr -d '\n' | sed "s${delimiter}$"
}

for file
do

  extension="$(echo "$file" | afterlast "\.")"
  echo "[guess_track_title] extension: $extension"
  filename="$(basename "$file" ".$extension")"
  echo "[guess_track_title] filename: $filename"

  blocks="$(echo "$filename" | split " - ")"

  artist=""
  album=""
  track=""

  if echo "$filename" | grep " - .* - " >/dev/null
  then
    artist="$(echo "$blocks" | head -n 1)"
    #album="$(echo "$blocks" | head -n 2 | tail -n 1)"
    album="$(echo "$blocks" | sed -n 2p)"
    track="$(echo "$blocks" | tail -n +3 | join " - ")"
  elif echo "$filename" | grep " - " >/dev/null
  then
    artist="$(echo "$blocks" | head -n 1)"
    track="$(echo "$blocks" | tail -n +2 | join " - ")"
  fi

  echo "Artist: $artist"
  echo "Album: $album"
  echo "Track: $track"

done
