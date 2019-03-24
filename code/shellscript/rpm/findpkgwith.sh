#!/bin/bash
## See also: apt-file search

if which pacman >/dev/null 2>&1
then
	pacman -Fo "$*"
	exit "$?"
fi

if which equery >/dev/null 2>&1
then
	equery belongs "$*"
	exit "$?"
fi

## dpkg
WEBSRCH=
while test ! "$2" = ""; do
	case "$1" in
		-web)
			WEBSRCH=true
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
	# PAGE="http://packages.debian.org/cgi-bin/search_contents.pl?word=$SEARCH&case=insensitive&version=testing&directories=yes"
	# PAGE="http://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=$SEARCH"
	PAGE="http://packages.debian.org/search?suite=default&section=all&arch=any&searchon=contents&keywords=$SEARCH"
	if xisrunning; then
		browse "$PAGE"
		# newwin lynx "$PAGE"
	else
		links "$PAGE"
	fi
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
# BIN="" ## No don't!
if [ ! "$BIN" ] || [ ! -x "$BIN" ]
then BIN=`jwhich dpkg`
fi

## TODO: dpkg now returns results of the style: <pkgname>, <another_pkg_name>: <file_found>
##       This is no good for the findorphanedfiles script.

$BIN -S "$SEARCH" | sed "s/^/"`cursecyan`"/;s/:/"`cursenorm`":/"
