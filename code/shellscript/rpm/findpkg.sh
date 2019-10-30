#!/bin/sh

if [ "x$1" = "x" ]
then
cat << '!'

findpkg [-all] [-web] [-big] <part-of-package-name>

  will list any packages you have installed matching "*<part-of-package-name>*".

    -all   will try to show matching uninstalled packages also.  But it does NOT
           actually show ALL under Debian (maybe it neglects virtual packages).

    -web   will open a browser to search the Debian package archive website.
           (Good alternative to -all.)

    -big   will set COLUMNS to something large, so that dpkg will produce full
           packagenames.

  findpkg currently supports dpkg systems (e.g. Debian and Ubuntu).

  BUG: dpkg does not display all packages, e.g. meta-packages used by apt.
  So rather than using:

    dpkg -l <glob>   or   findpkg <glob>

  I recommend instead using:

    aptitude --disable-columns search <regexp> | grep ^i

  I believe this problem exists with dlocate as well as dpkg.

!
exit 1
fi

## Somehow the values set in the while loop get preserved by the variables, even with /bin/sh above.
## So what's the problem with variables in while loops?  Mabe its only when piping?!
## It's because the while loop is not being piped into, for a change.
## That's what causes a separate sh to run and the vars to be localised so often.
SHOWALL=
WEBSRCH=
HEAD=
while test ! "$2" = ""
do
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
# for SEARCH; do ?



if which pacman >/dev/null 2>&1
then
	if [ -n "$ALL" ]
	then pacman -Ss "$SEARCH"
	else pacman -Qs "$SEARCH"
	fi |
	# -s searches not only package names, but also package descriptions
	# If we only want to match package names, we can do that now:
	grep -v "^\s" | grep -e "$SEARCH"
	exit
fi



if test $WEBSRCH
then
	PAGE="http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all"
	if xisrunning
	then
		browse "$PAGE"
		# newwin lynx "$PAGE"
	else
		lynx "$PAGE" &
	fi
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
SEARCHEXP="$SEARCH"
if [ -n "$USEDPKGOVERDLOCATE" ] || [ ! -x "$BIN" ]
then
  BIN=`jwhich dpkg`
  SEARCHEXP="*$SEARCH*"
fi





## Simple method:
# dpkg -l "*$@*" | egrep -v "^?n"
# dpkg -l "*$@*" | grep "^[hi]"


# Yum Cheatsheet: https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf
if which yum >/dev/null 2>&1
then
	if [ -n "$WEBSRCH" ]
	then yum provides "$SEARCHEXP"
	elif [ -n "$SHOWALL" ]
	then yum list available "$SEARCHEXP"
	else yum list installed "$SEARCHEXP"
	fi
	exit "$?"
fi



## Old method; presents output much like dpkg, but optionally with highlighting.
#
# Without the grep, both dpkg and dlocate used to find some non-installed
# packages, but didn't search all of them!  So we have stopped using it for
# SHOWALL, and switched to aptitude instead.
#
# apt-cache ia faster and available on more systems, but aptitude's output is
# more interesting (p/c/i).  Also apt-cache produces extra unwanted results
# (packages without kde in the name or the description!)
#
if [ -n "$SHOWALL" ]
then
	## dpkg calls dpkg-query.  I don't think it can list packages which aren't installed, can it?
	# $HEAD $BIN -l "$SEARCHEXP" | drop 5
	## aptitude and apt-cache can use SEARCH instead of SEARCHEXP.
	## apt-cache is a lot faster, but it doesn't list virtual packages, so we prefer to use aptitude if possible.

	# if which aptitude >/dev/null 2>&1
	# then aptitude search "$SEARCH"
	# else apt-cache search "$SEARCH"
	# fi

	## With caching:
	if which aptitude >/dev/null 2>&1
	then memo -nd -f /var/lib/apt/lists aptitude search .
	else memo -nd -f /var/lib/apt/lists apt-cache search ""
	fi |
	grep -E "$SEARCH"
else
	$HEAD $BIN -l "$SEARCHEXP" |
	drop 5 |   ## My dpkg's first five lines are headers
	grep -v "no description available"   ## skip this for SHOWALL
fi |
highlight "$SEARCH"



# ## New adaptation: looks up description of all packages using apt-cache show.
# ## TODO BUG: could miss packages if somehow they were shown by dpkg but did not have both Package and Description lines in apt-cache show.
# ## BUG: other bugs too
# 
# env COLUMNS=65535 $BIN -l "$SEARCHEXP" |
# takecols 2 |
# withalldo apt-cache show |
# grep "^\(Package\|Description\):" |
# while read HEADER REST
# do
	# [ "$HEADER" = "Package:" ] && PACKAGE="$REST"
	# [ "$HEADER" = "Description:" ] && echo "$PACKAGE	$REST"
# done | column -t -s "	" | removeduplicatelines
# 
# exit

