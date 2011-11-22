#!/bin/sh
# jsh-depends: del jdeltmp jgettmp
## Undoes contractsymlinks.
## Run this after doing cvs update, to restore symlinks from the
## .symlinks.links file.

## NOTE: Current version removes any already existing symlinks in the tree.  In
## other words it restores the state of the symlinks exactly from the file, in
## case any previous links have been deleted and removed from the file.

## Loses the dates on the symlinks, but I don't know how to set the symlink
## dates even if I had stored them.
## A tar can preserve symlink dates, but I want them to be diffable for makebackup.

(

	STARTDIR="$PWD"
	echo 'TMPFILE=`jgettmp expandsymlinks`'

	# echo 'find . -type l | foreachdo verbosely rmlink'
	# find . -type l | while read X; do echo "rmlink \"$X\""; done
	find . -type l | foreachdo verbosely rmlink

	cat .symlinks.list |
	removeduplicatelines |
	dog .symlinks.list

	cat .symlinks.list |
	# sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+cd ".\1"; ln -s "\3" "\2"; cd "'"$STARTDIR"'"+' |
	## Now keeps the symlink's parent dir's original time (does not update it on creation of new symlink)
	## Is this feature really worth the extra complexity and dependencies?!
	sed 's+^\(.*\)/\(.*\)	->	\(.*\)$+mkdir -p "\1"; touch -r "\1" "$TMPFILE"; cd "\1"; verbosely ln -s "\3" "\2"; cd "'"$STARTDIR"'"; touch -r "$TMPFILE" "\1"+'

	# echo "del .symlinks.list"

	echo 'jdeltmp "$TMPFILE"'

) | # highlightstderr pipeboth |

sh
