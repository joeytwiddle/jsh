if test "$*x" = "x"; then
  echo "tourl <incomplete-url> [ <relative-to-url> ]"
  exit 1
fi

# Is it an absolutely defined URL?
if startswith "$1" "http://"; then
  echo "$1"
elif startswith "$1" "ftp://"; then
  echo "$1"
elif startswith "$1" "file://"; then
  echo "$1"
# Second argument => resolve relative to that
elif test ! "x$2" = "x"; then
  if startswith "$1" "/"; then
    echo "http://$2$1"
  else
    echo "http://$2/$1"
  fi
# Try to find on filesystem
elif isabsolutepath "$1"; then
  echo "file://$1"
elif test -e $1; then
  echo "file://$PWD/$1"
else
# Assume it is a web-site
  echo "http://$1"
fi
