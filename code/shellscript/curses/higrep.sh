#!/bin/sh
# Recommended usage:
# higrep grepstring grepopts grepfiles
# -E to grep will not be passed to sed, but sed does regex =)

grep "$@" |
  # sed "s|^|"`cursecyan``cursebold`"|;s|:|"`cursegrey`":$TABCHAR|" |
  sed "s|^|"`cursecyan`"|;s|:|"`cursegrey`":$TABCHAR|" |
  # sed "s#$1#$CURSEON$1$CURSEOFF#g"
  highlight "$1"
# Not using highlight whilst developing clever color, but color code should go there

# drop 1 "$CNT" > "$CNT.tmp"
# mv "$CNT.tmp" "$CNT"
