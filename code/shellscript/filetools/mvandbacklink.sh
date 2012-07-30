if [ -z "$1" ] || [ -z "$2" ] || [ "$1" == --help ]
then cat << !

  mvandbacklink <nodes_to_move>... <destination_dir>

  will move the files/dirs into the destination dir,
  then link make a symlink to the new location.

!
exit 0
fi

DESTDIR=`lastarg "$@"`

for SRCNODE in "$@"
do
	## Skip the last arg when we reach it!
	[ "$SRCNODE" = "$DESTDIR" ] && continue
	verbosely mv "$SRCNODE" "$DESTDIR"/ &&
	verbosely ln -s "$DESTDIR"/"`filename "$SRCNODE"`" "$SRCNODE"
done
