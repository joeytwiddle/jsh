# jsh-ext-depends: dirname tee newer
# jsh-depends: unj endswith filename newer
# jsh-depends-ignore: jsh write
## cksum caching, re-checked when file is newer than cached cksum
## Unfortaunetly at the moment it doesn't provide any speed increase,
## at least in the presence of a small proportion of small files.
## Solutions: faster version (C) / drop small files immediately / batch version (multiple args)

## TODO: takecols 1 2 on cache not retrieval!

unj cksum "$@"
exit 0

while test ! "$1" = ""
do
	FILE="$1"
	shift
	if test ! -f "$FILE"
	then echo "cksum(jsh): ignoring non-file $FILE" >&2
	elif test ! -w "$FILE"
	then echo "Cannot write to $FILE"
	else
		DIR=`dirname "$FILE"`
		FILENAME=`filename "$FILE"`
		## Skip the flie if it is a jcksum itself!
		if ! endswith "$FILENAME" "\.jcksum"
		then
			CKSUMFILE="$DIR/.$FILENAME.jcksum"
			## Two lines below is the crux of the concept
			if test -f "$CKSUMFILE" &&
				newer "$CKSUMFILE" "$FILE"
			then
				## Oh bugger can this get any fiddlier?!
				# OUTPUT=`cat "$CKSUMFILE" | takecols 1 2`
				cat "$CKSUMFILE" |
				(
					read X Y Z
					## Um this is where the efficiency oozes from:
					echo "$X $Y $FILE"
				)
			else
				## Running but caching:
				unj cksum "$FILE" | tee "$CKSUMFILE"
			fi
		fi
	fi
done
