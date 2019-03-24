#!/bin/sh
page_url="${1}"
extension="${2}"

# Simple:
#   -np           Don't travel to parent folder

#wget -r -np -l 1 -A "${extension}" "${page_url}"

# Comprehensive:
#   -r            recursive
#   -l1           maximum recursion depth (1=use only this directory)
#   -H            span hosts (visit other hosts in the recursion)
#   -t1           Number of retries
#   -nd           Don't make new directories, put downloaded files in this one
#   -N            turn on timestamping
#   -A.mp3        download only mp3s
#   -erobots=off  execute "robots.off" as if it were a part of .wgetrc
#
# You can add more -A options if there are multiple extensions you wish to download.

wget -r -l1 -H -t1 -nd -N -np -A."${extension}" -erobots=off "${page_url}"
