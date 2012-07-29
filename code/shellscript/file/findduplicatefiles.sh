#!/bin/sh

[ "$1" = "" ] && jshwarn "findduplicatefiles-quick is actually much faster than findduplicatefiles without options.  You are recommended to use that until they are merged."
# jshwarn "Ofc scripting makes sense with findduplicatefiles, providing we will keep the I/O similar."

## WISHLIST:
## - instead of just deleting duplicates, also create a symlink in their place so they still function

## DONE:
## - order duplicates by least number of /s to bring us closer to automatic removal choice

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

SUGGEST_DEL=1
# SUGGEST_LN=1 ## BUG TODO: creates a symlink to ./blah which is ONLY correct if the src link is in .

if test "$1" = "" || test "$1" = "--help" || test "$1" = "-h"; then
	(
	echo
	# echo "findduplicatefiles [ -x <ex_regexp> ] [ -samename ] [ -qkck | -size ] <find_path>s.. [ <find_option>s.. ]"
	echo "findduplicatefiles [ <options> ] <find_path>s.. [ <find_option>s.. ]"
	echo "  where"
	echo "  <options> = [ -x <ex_regexp> ] [ -samename ] [ -qkck | -size ]"
	echo
	echo "The search has three stages:"
	echo
	echo "1) First files with the same size are grouped."
	echo
	## echo "    -samename : group only files with identical names (faster but incomplete)"
	echo "    -samename : skip check of files which have a unique filename"
	echo "      (can still match files with non-identical filenames, if both hashed!)"
	echo
	echo "2) Second, similar files are hashed (cksum) to ensure they really are identical."
	echo
	echo "    -qkck : use quick checksum, (only examine 16k at either end of the file)."
	echo "    -size : use file size instead of checksum (very fast but DANGEROUS)."
	echo
	echo "3) Finally redundant files deemed to have duplicates are suggested for removal."
	echo
	# echo "    TODO: output formats.  <-- ???!"
	echo "    Note: ATM it outputs results, but doesn't delete anything, so ph34r not!"
	echo
	echo "  You may wish to temporarily rename, move, or symlink the directories under"
	echo "  analysis into some alphanumeric order; since the first duplicate found is"
	echo "  kept; and all later duplicates are nominated for removal.  (See SORT_METHOD.)"
	echo
	) | more
	exit 1
fi

## OK well they aren't symlinks, because we use find -type f, and like it says hardlinks aren't a problem, so we don't need to display this message:
# echo "# Note: these could be hard links (but surely that isn't a problem, since one is always kept), or possibly symlinks (actually I think we skip these too, by using find -type f throughout :),"
# echo "# so make sure you don't delete the target!"
# echo

EXCLUDE_REGEXP=
if [ "$1" = -x ]
then
	EXCLUDE_REGEXP="$2"
	shift; shift
fi

stripexcluded () {
	if [ "$EXCLUDE_REGEXP" ]
	then grep -v "$EXCLUDE_REGEXP"
	else cat
	fi
}

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

# SORT_METHOD="sortbydirdepth" ## The one with the shorter dir depths (num of /s) gets kept.
SORT_METHOD="sort" ## Alphanumeric

# WHERE="$*"
# [ "$WHERE" ] || WHERE="."
## Better to use "$@" (prevents premature evaluation of glob, if user specified -name "*something*")

if [ "$SAMENAME" ]
then

	## Faster, because initially extracts duplicated filenames
	## If only two same-named files are grouped, they could be cmp-ed rather than hashed.
	find "$@" -type f |
	afterlast '/' |
	stripexcluded |
	# sed "s+\(.*\)/\(.*\)+\2 \1/\2+" |  ## More similar to other method (wouldn't need the inner find =) but would have a problem with spaced filenames
	keepduplicatelines |
	while read X
	do
		debug "Group $X"
		find "$@" -name "$X" |
	stripexcluded |
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

	## Whatever later we use (unless optimising with -samename), we first group by filesize.
	## This is different from the -filesize option which *matches* on filesize!
	## CONSIDER: If we replace %s with <filename> then we could do -samename in one method =)
	find "$@" -type f -printf "%s %p\n" |
	stripexcluded |
	keepduplicatelines 1 |
	sort -n -r -k 1 | ## optional; NO undesirable; it mucks up ordering!  Eh, how so?
	# dropcols 1 |
	while read SIZE FILE
	do
		debug "Hashing (size $SIZE) $FILE"
		$HASH "$FILE"
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
    ## The sorting method decides which one gets kept and which deleted:
    $SORT_METHOD
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
      then
        if [ "$SUGGEST_DEL" ]
        then echo "del \"$FILE2\""
        elif [ "$SUGGEST_LN" ]
        then echo "ln -s -f \"$PWD/$FILE\" \"$FILE2\""
        else echo "echo dunno how to handle \"$FILE\""
        fi
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
		echo "del \"$FILE\""
	else
		echo "# Unique: ($X $Y) \"$FILE\""
	fi
	echo
	LASTX="$X"
	LASTY="$Y"
done

exit
