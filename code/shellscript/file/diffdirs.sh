#!/bin/bash

# It was /bin/sh until we added -filesonly

# jsh-depends: cursebold cursegreen cursered curseyellow cursenorm removeduplicatelines filesize diffsummary list2regexp
# jsh-ext-depends: diff find
# jsh-depends-ignore: findfiles
# jsh-ext-depends-ignore: sort sed
# jsh-depends-ignore: findfiles

# Alternative, use diff's recursive option:
#   diff -r dir1 dir2

# See also: diff --brief -r

# Compare filenames only
# TODO: Add file sizes to the find
if [ "$1" = -filesonly ]
then
	shift
	diff <(cd "$1" && find . | sort) <(cd "$2" && find . | sort)
	exit "$?"
fi

## Consider: Instead of "Only in ..." use "Missing" and "Added" when comparing state of second wrt first.
## BUG TODO: Does not do the right thing with broken symlinks - spews errors instead.

## Defaults:
#[ -z "$SHOWDIFFSWITH" ] && SHOWDIFFSWITH="diff"
#[ -z "$SHOWDIFFSWITH" ] && SHOWDIFFSWITH="echo xterm -geometry 140x60 -e vimdiff" ## prebg

DEFAULT_IGNORE_REGEXP="\(^\|/\)\(\.git/\|CVS/\|\.svn/\|node_modules/\|\..*\.sw.$\)"

if [ "$1" = -showdiffswith ]
then
	SHOWDIFFSWITH="$2"
	shift; shift
fi

DIRA="$1"
DIRB="$2"

if [ -z "$DIRA" ] || [ -z "$DIRB" ] || [ "$1" = --help ]
then
cat << !

[<<options>] diffdirs <dira> <dirb>

  shows a summary of which files in dira and dirb are identical, unique or
  different.

If provided, these options can be used to select files by filenames:

  ONLY_REGEXP="/src/"

  IGNORE=".class"
    or
  IGNORE_REGEXP="\.class$"

  DEFAULT_IGNORE_REGEXP="$DEFAULT_IGNORE_REGEXP"

If neither are specified, IGNORE_REGEXP will apply some common excludes,
including .git and node_modules folders.

To skip reporting identical files:

  NOMATCHES=1 or NM=1

Options:

  -showdiffswith <cmd>

  e.g. -showdiffswith 'diff -u'

Or, display or inspect diffs respectively (and sequentially):

  # Show differences inline
  SHOWDIFFSWITH=prettydiff
  # Pop up a separate xterm for each difference
  SHOWDIFFSWITH="xterm -geometry 140x60 -e vimdiff"
  # Make a suggestion which the user can copy paste
  SHOWDIFFSWITH="echo vimdiff"

  NOTE: -showdiffswith MUST NOT BE used with vimdiff directly, because stdin has already been captured

!
exit 0
fi





. "$JPATH"/tools/faster_jsh_colors.init



# [ "$IGNORE" ] && IGNORE_REGEXP="\(""`echo "$IGNORE" | tr ',' '\n' | while read IGNORETERM; do echo "$(toregexp "$IGNORETERM")"; echo "\|"; done; echo "impossible\)"`""\)"
[ -n "$IGNORE" ] && IGNORE_REGEXP="` echo "$IGNORE" | tr ',' '\n' | list2regexp `"
[ -n "$IGNORE_REGEXP" ] || IGNORE_REGEXP="$DEFAULT_IGNORE_REGEXP"

findfiles () {
	cd "$1" || exit 1
	# find . -type f
	find . -type f -or -type l | grep -v "$IGNORE_REGEXP" | sed 's+^\./++' | sort
}

IDCNT=0

report() {
	if [ "$IDCNT" -gt 0 ]
	then
		[ "$IDCNT" -gt 1 ] && /bin/echo -n " [$IDCNT files]"
		/bin/echo
		IDCNT=0
	fi
	/bin/echo "$@"
}

identical() {
	[ -n "$NOMATCHES" ] && return
	if [ "$IDCNT" = 0 ]
	then /bin/echo -n "${CURSEBLUE}Identical:${CURSENORM}" "$@"
	else /bin/echo -n "" "$@"
	fi
	IDCNT=$((IDCNT+1))
}

isbrokenlink() {
	[ -L "$1" ] && ! [ -d "$1" ] && ! [ -f "$1" ]
}

# We used to check the size only.  That is faster if the files are identical but have different dates.  But it is also prone to skip fixed-length files whose content might be different!  So it is more accurate to check both.  (Although it's still not 100%!)
get_size_and_date() {
	stat -c '%s %Y' "$@"
}


[ -n "$NM" ] && NOMATCHES="$NM"

(
	( findfiles "$DIRA" )
	( findfiles "$DIRB" )
	exit 55   # does nothing - we cannot abort the entire chain if one of the above fail
) |

if [ -n "$ONLY_REGEXP" ]
then grep "$ONLY_REGEXP"
else cat
fi |

removeduplicatelines |

while read FILE
do

	# TODO: Some of the symlink handling code could be reduced using readlink

	## TODO: Link handling is not complete for fringe cases
	if [ -L "$DIRA/$FILE" ] && [ -L "$DIRB"/"$FILE" ]
	then
		LINKA="`justlinks "$DIRA/$FILE"`"
		LINKB="`justlinks "$DIRB/$FILE"`"
		if [ "$LINKA" = "$LINKB" ]
		then [ -z "$NOMATCHES" ] && report "${CURSEBLUE}Identical symlinks:${CURSENORM} $FILE"
		else report "${CURSEYELLOW}Differing symlinks:${CURSENORM} $DIRA/$FILE -> $LINKA but $DIRB/$FILE -> $LINKB"
		fi
		continue
	fi

	if [ -L "$DIRA/$FILE" ] && [ ! -L "$DIRB/$FILE" ]
	then
		report "${CURSEYELLOW}A is a symlink, B is not!${CURSENORM} $FILE"
		continue
	fi
	if [ ! -L "$DIRA/$FILE" ] && [ -L "$DIRB/$FILE" ]
	then
		report "${CURSEYELLOW}B is a symlink, A is not!${CURSENORM} $FILE"
		continue
	fi

	## Avoids errors, but does not actually compare the links!  (Sometimes the other one does not exist at all.)
	if isbrokenlink "$DIRA/$FILE"
	then
		report "${CURSEYELLOW}Is a broken symlink:${CURSENORM} $DIRA/$FILE"
		continue
	fi
	if isbrokenlink "$DIRB/$FILE"
	then
		report "${CURSEYELLOW}Is a broken symlink:${CURSENORM} $DIRB/$FILE"
		continue
	fi

	if [ ! -e "$DIRA/$FILE" ] && [ -e "$DIRB/$FILE" ] ## Second check is in case both are broken symlinks, although TODO: should really check targets are the same
	then
		[ -z "$HIDE_ADDS" ] && report "${CURSEGREEN}+ Only in $DIRB/: $FILE${CURSENORM}"
	elif [ ! -e "$DIRB/$FILE" ] && [ -e "$DIRA/$FILE" ] ## Second check is in case both are broken symlinks, although TODO: should really check targets are the same
	then
		[ -z "$HIDE_REMOVALS" ] && report "${CURSERED}${CURSEBOLD}- Only in $DIRA/: $FILE${CURSENORM}"
	else

		## Check the file contents
		# if cmp "$DIRA/$FILE" "$DIRB/$FILE" 2> /dev/null

		## These are faster alternatives, but not as thorough:
		## Actually they are probably slower for small files, but significantly faster for any large files we come across.

		## Check only file size
		## Note: this detects a symlink to an identical file as different!
		# if [ "`filesize "$DIRA/$FILE"`" = "`filesize "$DIRB/$FILE"`" ]

		## Check file size and last modified time, but allow it to pass if modified time were different but contents are the same.
		filestats_a="`filesize "$DIRA/$FILE"`"
		filestats_b="`filesize "$DIRB/$FILE"`"
		#filestats_a="`get_size_and_date "$DIRA/$FILE"`"
		#filestats_b="`get_size_and_date "$DIRB/$FILE"`"
		if [ "$filestats_a" = "$filestats_b" ] || (cmp "$DIRA/$FILE" "$DIRB/$FILE" >/dev/null 2>&1)

		# if test "`qkcksum "$DIRA/$FILE" | takecols 1 2`" = "`qkcksum "$DIRB/$FILE" | takecols 1 2`" ## only faster for bigger files!
		## This was no good, because the filenames are different, and are echoed back!: if [ "`qkcksum \"$DIRA/$FILE\"`" = "`qkcksum \"$DIRB/$FILE\"`" ]
		## This does not work on files with spaces: # if test "`qkcksum \`realpath "$DIRA/$FILE"\` | takecols 1 2`" = "`qkcksum \`realpath "$DIRB/$FILE"\` | takecols 1 2`" ## only faster for bigger files!

		then
			# /bin/echo -e -n "\rIdentical: $FILE   "
			identical "$FILE"
		# else report "Differ: $FILE"
		else
			# report "${CURSEYELLOW}Differ: diff \"$DIRA/$FILE\" \"$DIRB/$FILE\"${CURSENORM}"
			DIFFSUMMARY=`NOEXEC=1 IKNOWIDONTHAVEATTY=1 diffsummary "$DIRA/$FILE" "$DIRB/$FILE"`
			report "${CURSEYELLOW}# Differ: $FILE${CURSENORM}"
			if [ -n "$SHOWDIFFSWITH" ]
			then $SHOWDIFFSWITH "$DIRA/$FILE" "$DIRB/$FILE"
			fi
		fi
	fi

done

## Dammit we lost our value of IDCNT!
# if [ "$IDCNT" -gt 0 ]
# then echo
# fi
echo

