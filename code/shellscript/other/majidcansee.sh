for X in "$@"; do
  if test -f $X; then
    setfacl -f $HOME/facl.file $X
  elif test -d $X; then
    setfacl -f $HOME/facl.dir $X
  fi
done
