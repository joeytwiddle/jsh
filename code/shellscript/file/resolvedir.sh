if isabsolutepath $1; then
  echo $1
elif test -e "$PWD/$1"; then
  echo $PWD/$1
fi