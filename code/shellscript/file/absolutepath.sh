if isabsolutepath "$@"; then
  echo "$@"
else
  echo "$PWD/$@"
fi