(
	STARTDIR="$PWD"
	TMPFILE=`jgettmp expandsymlinks`
	cat .symlinks.list |
	# sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+cd ".\1"; ln -s "\3" "\2"; cd "'"$STARTDIR"'"+' |
	## Now keeps the symlink's parent dir's original time (does not update it on creation of new symlink)
	sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+touch -r "\1" '"$TMPFILE"'; cd "\1"; ln -s "\3" "\2"; cd "'"$STARTDIR"'"; touch -r '"$TMPFILE"' "\1"+'
	echo "del .symlinks.list"
	echo "jdeltmp $TMPFILE"
) | # pipeboth |

sh
