## Undoes contractsymlinks.
## Loses the dates on the symlinks, but I don't know how to set the symlink
## dates even if I had stored them.
## A tar can preserve symlink dates, but I want them to be diffable for makebackup.

(
	STARTDIR="$PWD"
	TMPFILE=`jgettmp expandsymlinks`
	cat .symlinks.list |
	# sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+cd ".\1"; ln -s "\3" "\2"; cd "'"$STARTDIR"'"+' |
	## Now keeps the symlink's parent dir's original time (does not update it on creation of new symlink)
	sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+mkdir -p "\1"; touch -r "\1" '"$TMPFILE"'; cd "\1"; ln -s "\3" "\2"; cd "'"$STARTDIR"'"; touch -r '"$TMPFILE"' "\1"+'
	echo "del .symlinks.list"
	echo "jdeltmp $TMPFILE"
) | # pipeboth |

sh
