# Recommended usage:
# higrep grepstring grepopts+grepfiles
grep "$@" |
  # sed "s|^|"`cursecyan``cursebold`"|;s|:|"`cursegrey`":$TABCHAR|" |
  sed "s|^|"`cursecyan`"|;s|:|"`cursegrey`":$TABCHAR|" |
  highlight $1
