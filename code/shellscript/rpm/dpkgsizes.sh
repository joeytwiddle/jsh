# noop > totals.txt
env COLUMNS=184 dpkg -l | drop 5 | takecols 2 | while read X; do
  FILES=`dpkg -L $X | while read Y; do
    if test -f "$Y"; then
      echo "$Y"
    fi
  done`
  DUSK=`dusk "$FILES"`
  # echo "$DUSK" > files-"$X".txt
  PKGSIZE=`echo "$DUSK" | takecols 1 | awksum`
  echo -e "$PKGSIZE\t$X" # >> totals.txt
done
