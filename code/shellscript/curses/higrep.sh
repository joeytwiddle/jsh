# Recommended usage:
# higrep grepstring grepopts+grepfiles
grep "$@" | 
  sed "s|^|"`cursewhite``cursebold`"|;s|:|"`cursegrey`":$TABCHAR|" |
  highlight $1
