#!/bin/sh
if test "$1" = ""; then
  echo "findpkg [-all] [-web] [-big] <part-of-package-name>"
  exit 1
fi

## Somehow the values set in the while loop get preserved by the variables, even with /bin/sh above.
## So what's the problem with variables in while loops?  Mabe its only when piping?!
## It's because the while loop is not being piped into, for a change.
## That's what causes a separate sh to run and the vars to be localised so often.
SHOWALL=
WEBSRCH=
HEAD=
while test ! "$2" = ""; do
	case "$1" in
		-all)
			SHOWALL=true
		;;
		-web)
			WEBSRCH=true
		;;
		-big)
			# extend columns in order to show full package name and description
			HEAD="env COLUMNS=184"
		;;
		*)
			echo "$1: invalid argument"
			exit 1
		;;
	esac
	shift
done
SEARCH="$1"

if test $WEBSRCH; then
	PAGE="http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all"
	if xisrunning; then
		browse "$PAGE"
		# newwin lynx "$PAGE"
	else
		lynx "$PAGE" &
	fi
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
## NO don't, because it stopped working properly on my system!
BIN=""
SEARCHEXP="$SEARCH"
if test "$USEDPKGOVERDLOCATE" || test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
  SEARCHEXP="*$SEARCH*"
fi



# ## New adaptation: looks up description of all packages using apt-cache show.
# ## TODO BUG: could miss packages if somehow they were shown by dpkg but did not have both Package and Description lines in apt-cache show.
# ## BUG: other bugs too
# 
# env COLUMNS=65535 $BIN -l "$SEARCHEXP" |
# takecols 2 |
# withalldo apt-cache show |
# grep "^\(Package\|Description\):" |
# while read HEAD REST
# do
	# [ "$HEAD" = "Package:" ] && PACKAGE="$REST"
	# [ "$HEAD" = "Description:" ] && echo "$PACKAGE	$REST"
# done | column -t -s "	" | removeduplicatelines
# 
# exit



## Old method; presents output much like dpkg, but optionally with highlighting.

$HEAD $BIN -l "$SEARCHEXP" |
drop 5 | ## My dpkg's first five lines are headers
if [ $SHOWALL ]
then cat
else grep -v "no description available"
fi | highlight "$SEARCH"

# dpkg -l "*$@*" | egrep -v "^?n"
# dpkg -l "*$@*" | grep "^[hi]"
