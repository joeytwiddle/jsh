#!/bin/sh

## A one-line alternative: find . ! -empty -type f -exec sh -c 'md5sum "$1"' _ {} \; | sort | uniq -w32 -dD

## We are now doing size comparison when -samename is off.  So findduplicatefiles-quick is deprecated.
# [ -z "$1" ] && jshwarn "findduplicatefiles-quick is actually much faster than findduplicatefiles without options.  You are recommended to use that until they are merged."
# jshwarn "Ofc scripting makes sense with findduplicatefiles, providing we will keep the I/O similar."

## DONE: Recommend automatic (TODO: optional) rejection of 0-length files, since these are always seen as duplicates, contain no data, and are more often useful for their filename, not their data.  Note: NOT done for -samename!

## WISHLIST:
## - instead of just deleting duplicates, also create a symlink in their place so they still function

## DONE:
## - order duplicates by least number of /s to bring us closer to automatic removal choice

# readgroup () {
	# while read LINE
	# do
		# [ ! "$LINE" ] && break
		# echo "$LINE" >&2
	# done
# }

debug () {
	echo "$*" >&2
	# noop
}

[ -z "$SUGGEST_LN" ] && SUGGEST_DEL=1
# SUGGEST_LN=1 ## BUG TODO: creates a symlink to ./blah which is ONLY correct if the src link is in .

if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
more << !

findduplicatefiles [ <options> ] <find_path>s.. [ <find_option>s.. ]

  Options must be given in the correct order:

<options> = [ -x <ex_regexp> ] [ -samename ] [ -qkck | -size ]

  will list duplicate files (by checksum), in a form that can be piped through
  |sh to remove copies, retaining just one of each file.

  -x <regexp> : a quick way to exclude certain files from consideration.

The search has three stages:

1) First files with the same size are grouped.  Or with

  -samename : Only check files whose name appears more than once

    A speed optimization if you know identical files will have the same name.
    (Actually only significantly faster if there are *many* non-duplicate files
    of matching size but different name.)
    Might still match files with non-identical filenames, if both were hashed.
    Since this replaces the group-by-size method, it could under some
    circumstances produce larger groups!
    The grouping process is also a large overhead.

2) Second, similar files are hashed (cksum) to ensure they really are identical.

    -qkck : Use quick checksum, (for huge files, only examines 16k at either
            end of the file).  May generate false positives but no false -ves.

    -size : Use file size instead of checksum (very fast but very DANGEROUS!).

3) Finally redundant files deemed to have duplicates are suggested for removal.

To actually delete redundant files, do not add -do or --force, add |sh

You may wish to temporarily rename, move, or symlink the directories under
analysis into some alphanumeric order; since the first duplicate found is kept;
and all later duplicates are nominated for removal.  (See SORT_METHOD.)

But be careful doing find */ or find -follow through *symlinks with matching
targets* as this will present the same files with different paths, and mark
them as duplicates.

!
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
if [ "$1" = "-samename" ]
then
	SAMENAME=true
	shift
fi

HASH="cksum"
if [ "$1" = "-qkck" ]
then
	shift
	HASH="qkcksum"
elif [ "$1" = "-size" ]
then
	shift
	HASH="filesize -likecksum"
	# echo 'Possible usage: findduplicatefiles -size | while read X Y Z; do if [ "$Z" ]; then cksum "$Z"; else echo; fi done' >> /dev/stderr
fi

if [ -z "$SORT_METHOD" ]
then
	SORT_METHOD="sortbydirdepth -r" ## The one with the shorter dir depths (num of /s) gets kept.
	# SORT_METHOD="sort -r" ## Alphanumeric
fi

# WHERE="$*"
# [ "$WHERE" ] || WHERE="."
## Better to use "$@" (prevents premature evaluation of glob, if user specified -name "*something*")

if [ -n "$SAMENAME" ]
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
		find "$@" -type f -name "$X" |   ## This didn't have -type f before but I added it
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

	## Group by size and keep only files which have a duplicate size.
	## Whatever later we use (unless optimising with -samename), we first group by filesize.
	## This is different from the -filesize option which *matches* on filesize!
	## CONSIDER: If we replace %s with <filename> then we could do -samename in one method =)
	find "$@" -type f -printf "%s %p\n" |
	stripexcluded |
  ## Skip files of 0 length:
	grep -v "^0 " |
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
  [ -z "$EMPTY" ] || error "Expected empty line; got \"$EMPTY\""
  echo

  while read LINE
  do
    (
      echo "$LINE"
      while read LINE
      do
        if [ -n "$LINE" ]
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
  [ -z "$EMPTY" ] || error "Expected empty line; got \"$EMPTY\""

  while read SUM SIZE FILE
  do
    if [ -z "$SUM" ]
    then
      error "## Unexpected empty line"
      continue
    fi
    echo "## $SUM $SIZE :"
    echo "# -- $FILE"
    while read SUM2 SIZE2 FILE2
    do
      if [ -z "$SUM2" ]
      then break
      fi
      if [ "$SUM" = "$SUM2" ] && [ "$SIZE" = "$SIZE2" ]
      then
        if [ -n "$SUGGEST_DEL" ]
        then echo "del \"$FILE2\""
        elif [ -n "$SUGGEST_LN" ]
        # then echo "ln -s -f \"$PWD/$FILE\" \"$FILE2\""   ## Bad: $FILE may be absolute already
        then
          realLink=`absolutepath "$FILE"`
          if [ -n "$PARANOID_BACKUP" ]
          then
            backupFile="/tmp/`basename "$FILE2"`.`date +'%s.%N'`"
            echo "cp \"$FILE2\" \"$backupFile\""
          else
            echo "del \"$FILE2\""
          fi
          echo "ln -s -f \"$realLink\" \"$FILE2\""
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
	# # [ ! "$GROUP" ] && break
# done

exit



## OLD: A simple version which just sorts by checksum, then looks for adjacent duplicates.

LASTX=
LASTY=

cksumall "$@" |

sort |

while read X Y FILE
do
	if [ "$X" = "$LASTX" ] && [ "$Y" = "$LASTY" ]
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
