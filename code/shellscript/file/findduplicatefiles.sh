## WISHLIST:
# - order duplicates by least number of /s to bring us closer to automatic removal choice

if test "$1" = "" || test "$1" = "--help" || test "$1" = "-h"; then
	echo "findduplicatefiles [ -samename ] [ -qkck | -size ] <files/directories>..."
	echo "  The search is done in two stages.  First files with the same size are found."
	echo "    -samename : extract only files with identical names (faster)"
	echo "  Second, the files are hashed (cksum) to check if they really are identical."
	echo "    -qkck : use quick checksum, (only examine 16k at either end of file)"
	echo "    -size : use file size instead of checksum (much faster but DANGEROUS)."
	exit 1
fi

echo "Note: these could be hard links, or possibly (to check) symlinks,"
echo "so make sure you don't delete the target!"
echo

SAMENAME=
if test "$1" = "-samename"
then
	SAMENAME=true
	shift
fi

HASH="cksum"
if test "$1" = "-qkck"
then
	shift
	HASH="qkcksum"
elif test "$1" = "-size"
then
	shift
	HASH="filesize -likecksum"
	# echo 'Possible usage: findduplicatefiles -size | while read X Y Z; do if test "$Z"; then cksum "$Z"; else echo; fi done' >> /dev/stderr
fi

WHERE="$*"
test "$WHERE" || WHERE="."

if test $SAMENAME
then

	# Faster, because initially extracts duplicated filenames
	find $WHERE -type f |
	sed "s+.*/++" |
	keepduplicatelines |
	while read X
	do
		find . -name "$X" |
		while read Y
		do $HASH "$Y"
		done
	done |
	keepduplicatelines -gap 1 2

else

	find $WHERE -type f -printf "%s %p\n" |
	keepduplicatelines 1 |
	afterfirst " " |
	while read X
	do $HASH "$X"
	done |
	keepduplicatelines -gap 1 2

fi |

sed 's/[0123456789]* [0123456789]* \(.*\)/del "\1"/'

exit

## A simple version which just sorts by checksum, then looks for adjacent duplicates.

LASTX=
LASTY=

cksumall "$@" |

sort |

while read X Y FILE
do
	if test "$X" = "$LASTX" && test "$Y" = "$LASTY"
	then
		echo "# Redund: ($X $Y) \"$FILE\""
		echo "echo \"Deleting \\\"$FILE\\\"\""
		echo "rm \"$FILE\""
	else
		echo "# Unique: ($X $Y) \"$FILE\""
	fi
	echo
	LASTX="$X"
	LASTY="$Y"
done

exit
