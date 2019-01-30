#!/bin/bash

if [ "$2" = "" ] || [ "$1" = --help ]
then cat << !
wget_all_links_with_extension <url> <extension>

  will fetch the given HTML page, and then download all links on that page which match the given extension.
!
exit
fi

url="$1"
ext="$2"
shift; shift

wget -r -l 1 -H -A "$ext" "$url"
