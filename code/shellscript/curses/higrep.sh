# Recommended usage:
# higrep grepstring grepopts+grepfiles
grep "$@" |
  sed "s|^|"`cursecyan``cursebold`"|;s|:|"`cursegrey`":$TABCHAR|" |
  highlight $1
