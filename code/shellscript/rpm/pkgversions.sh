#!/bin/sh
# jsh-ext-depends-ignore: dpkg
# jsh-ext-depends: sed apt-cache
# jsh-depends: cursecyan cursenorm drop tostring

if [ "$1" = -all ]
then
	shift
	altList=/etc/apt/all-sources.list
	[ -f "$altList" ] && APT_CACHE_OPTIONS="$APT_CACHE_OPTIONS --option Dir::Etc::sourcelist=$altList" || echo "Source list $altList not found."
fi

if [ "$1" = "-search" ]
then
	shift
	COLUMNS=160 findpkg -all "$1" | striptermchars | takecols 2 | withalldo pkgversions
	exit
fi
# e.g.: pkgversions `findpkg xserver | striptermchars | takecols 2`

## TODO: Change "[Selected]" to "[Installed]" to be accurate, but also check for dependencies on it by other scripts!
## Doh!  See also: apt-show-versions
## See also: dpkg --print-avail

if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

pkgversions [-all] [-search] <package_name>...

  will show packages available with the given name.

  -search : allow partial name matches

  -all : use alternate source list

!
	exit
fi

for PKG in "$@"
do

	CURRENT_VERSION=`COLUMNS=160 dpkg -l | grep "^..  $PKG " | takecols 3`
	CURRENT_VERSION_RE=`toregexp "$CURRENT_VERSION"`
	# echo "CURRENT_VERSION=$CURRENT_VERSION"

	# apt-cache show "$PKG" | grep "^Version: " |

	apt-cache $APT_CACHE_OPTIONS showpkg "$PKG" |
	grep "/var/lib/\(apt\|dpkg\)/" |
	grep -v "^[ 	]*File: " |
	sed 's+/var/lib/dpkg/status+installed+' |
	sed 's+/var/lib/apt/lists/++g' |
	sed 's+\(dists_\|debian_\|_binary-i386_Packages\)++g' |

	# ( [ "$1" != "$*" ] && prepend_each_line "$PKG=" || cat ) |
	prepend_each_line "$PKG=" |

	( [ "$CURRENT_VERSION" ] && highlight "$CURRENT_VERSION_RE" || cat )

	if [ "$1" != "$*" ]
	then echo # ; echo "$PKG:"
	fi

	continue

	apt-cache $APT_CACHE_OPTIONS showpkg "$PKG" 2>/dev/null |
	drop 2 |
	tostring "" |
	# Why doesn't this line work?!
	sed 's+(security[^)]*_dists_\([^_]*\)_[^)]*)+(security:\1)+g' |
	sed 's+([^)]*_dists_\([^_)]*\)_main_[^)]*)+(\1)+g' |
	sed 's+^\(.*\)(/var/lib/dpkg/status)\(.*\)$+\1\2 '`cursecyan`'[Selected]'`cursenorm`'+' |
	# Following two equivalent:
	sed 's+/var/lib/apt/lists/++g'
	# sed 's+([^)]*/\([^)]*\))+(\1)+g'

done

