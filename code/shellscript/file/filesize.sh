if test "$1" = "-likecksum"; then
	shift
	'ls' -l "$@" |
		grep -v "^total " |
		while read PERM INODE OWNER GROUP SIZE DM DD TIME FILENAME; do
			echo "0 $SIZE	$FILENAME"
		done
else
	'ls' -l "$@" |
		takecols 5
fi
