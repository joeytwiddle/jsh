## WISHLIST:
# - order duplicates by least number of /s to bring us closer to automatic removal choice

# readgroup () {
	# while read LINE
	# do
		# test ! "$LINE" && break
		# echo "$LINE" >&2
	# done
# }

debug () {
	echo "$*" >&2
	# noop
}

if test "$1" = "" || test "$1" = "--help" || test "$1" = "-h"; then
	echo "findduplicatefiles [ -samename ] [ -qkck | -size ] <files/directories>..."
	echo "  The search has three stages:  First files with the same size are grouped."
	## echo "    -samename : group only files with identical names (faster but incomplete)"
	echo "    -samename : do not check files which have a unique filename"
	echo "  Second, similar files are hashed (cksum) to ensure they really are identical."
	echo "    -qkck : use quick checksum, (only examine 16k at either end of file)"
	echo "    -size : use file size instead of checksum (very fast but DANGEROUS)."
	echo "  Finally redundant files deemed to have duplicates are suggested for removal."
	echo "    TODO: output formats."
	echo "    Note: ATM it outputs results, but doesn't delete anything, so ph34r not!"
	exit 1
fi

echo "# Note: these could be hard links, or possibly (to check) symlinks,"
echo "# so make sure you don't delete the target!"
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

	## Faster, because initially extracts duplicated filenames
	## If only two same-named files are grouped, they could be cmp-ed rather than hashed.
	find $WHERE -type f |
	afterlast '/' |
	# sed "s+\(.*\)/\(.*\)+\2 \1/\2+" |  ## More similar to other method (wouldn't need the inner find =) but would have a problem with spaced filenames
	keepduplicatelines |
	while read X
	do
		debug "Group $X"
		find $WHERE -name "$X" |
		while read Y
		do
			debug "Hashing $Y"
			$HASH "$Y"
		done
		debug
	done |
	keepduplicatelines -gap 1 2
	# cat

else

	## Whatever method we use (other than -samename), we first group by filesize.
	## This is different from the -filesize option which matches on filesize!
	## If we replace %s with <filename> then we can do -samename in one method =)
	find $WHERE -type f -printf "%s %p\n" |
	keepduplicatelines 1 |
	dropcols 1 |
	while read X
	do
		debug "Hashing $X"
		$HASH "$X"
	done |
	keepduplicatelines -gap 1 2

fi |

# sed 's/[a-zA-Z0-9]* [0-9]* \(.*\)/del "\1"/'
# dropcols 1 2 | sed 's|^\(.\+\)|del "\1"|'
# sed 's|\([0-9]+[ 	]+[0-9]+\)[ 	]+\(.+\)|\1: del "\2"|'
# cat

## Sort each group by directory depth, so that lowest file is the one kept:
(

  read EMPTY
  test "$EMPTY" = "" || error "Expected empty line; got \"$EMPTY\""
  echo

  while read LINE
  do
    (
      echo "$LINE"
      while read LINE
      do
        if test "$LINE"
        then echo "$LINE"
        else break
        fi
      done
    ) |
    sortbydirdepth
    echo
  done

) |

## Pretty print each group, suggesting deletion of all but the first file in each:
(

  read EMPTY
  test "$EMPTY" = "" || error "Expected empty line; got \"$EMPTY\""

  while read SUM SIZE FILE
  do
    if test "$SUM" = ""
    then
      error "## Unexpected empty line"
      continue
    fi
    echo "## $SUM $SIZE :"
    echo "# -- $FILE"
    while read SUM2 SIZE2 FILE2
    do
      if test "$SUM2" = ""
      then break
      fi
      if test "$SUM" = "$SUM2" && test "$SIZE" = "$SIZE2"
      then echo "del \"$FILE2\""
      else error "$SUM $SIZE for \"$FILE\" does not match $SUM2 $SIZE2 for \"$FILE2\""
      fi
    done
    echo
  done

)

# while readgroup
# do
	# echo "GROUP:"
	# echo "$GROUP"
	# # test ! "$GROUP" && break
# done

exit

## OLD: A simple version which just sorts by checksum, then looks for adjacent duplicates.

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
