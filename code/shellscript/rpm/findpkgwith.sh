#!/bin/bash
## See also: apt-file search
## See also: find_package_with_file.*.sh

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

if [ -n "$WEBSRCH" ]
then
	open_url() {
		if xisrunning
		then
			browse "$1"
			# newwin lynx "$1"
		else
			links "$1"
		fi
	}

	if command -v yum >/dev/null 2>&1
	then
		yum whatprovides "$SEARCH"
		exit "$?"
	fi

	if command -v dpkg >/dev/null 2>&1
	then
		# PAGE="http://packages.debian.org/cgi-bin/search_contents.pl?word=$SEARCH&case=insensitive&version=testing&directories=yes"
		# PAGE="http://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=$SEARCH"
		PAGE="http://packages.debian.org/search?suite=default&section=all&arch=any&searchon=contents&keywords=$SEARCH"
		open_url "$PAGE"
		exit "$?"
	fi

	if command -v rpm >/dev/null 2>&1
	then
		PAGE="http://www.rpmfind.net/linux/rpm2html/search.php?query=$SEARCH"
		open_url "$PAGE"
		exit "$?"
	fi

	if command -v apk >/dev/bull 2>&1
	then
		dirname="$(dirname "$SEARCH")"
		filename="$(basename "$SEARCH")"
		if ! grep "^/" <<< "$dirname" >/dev/null
		then
			echo "Error: You must provide the full path: $dirname"
			exit 1
		fi
		PAGE="https://pkgs.alpinelinux.org/contents?file=${filename}&path=${dirname}&name=&branch=edge"
		open_url "$PAGE"
		exit "$?"
	fi

	echo "I do not know how to search available packages for your package manager"
	exit 5
fi

if command -v pacman >/dev/null 2>&1
then
	pacman -Qo "$*"
	exit "$?"
fi

if command -v equery >/dev/null 2>&1
then
	equery belongs "$*"
	exit "$?"
fi

if command -v rpm >/dev/null 2>&1
then
	# find_package_with_file.rpm.sh
	rpm -qf "$@"
	exit "$?"
fi

# use dlocate if it's available
BIN="$(jwhich dlocate)"
# BIN="" ## No don't!
if [ ! "$BIN" ] || [ ! -x "$BIN" ]
then BIN="$(jwhich dpkg)"
fi

## TODO: dpkg now returns results of the style: <pkgname>, <another_pkg_name>: <file_found>
##       This is no good for the findorphanedfiles script.

"$BIN" -S "$SEARCH" | sed "s/^/$(cursecyan)/ ; s/:/$(cursenorm):/"
