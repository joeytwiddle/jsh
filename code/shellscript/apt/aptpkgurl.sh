## This is much quicker than apt-get, but of course it doesn't resolve dependencies.
## Try doing this: aptpkgurl <pkgname> | striptermchars | grep -A3 "_testing_" | grep "^http"
## OK, so that gets us URLs to d/l from.
## And maybe we can use apt-cache showpkg to quickly resolve dependencies...?  (It seems to match desired to installed if it exists =)

## TODO: offer alternative mode, which uses debian website's package search
##       and find URLs for package sources that way, without requiring local apt source cache.

## Not working for security.debian.org (they have strange paths)

# grep "$1.*\.deb$" /var/lib/apt/lists/* 2> /dev/null |

if test "$1" = "-src"
then

	shift

	## Until automatic memo garbage collection is implemented, these memo calls are bloating $JPATH/data !
	memo grep "$1.*\.dsc" /var/lib/apt/lists/*Sources

else

	memo grep "^Filename: " /var/lib/apt/lists/*Packages |
	grep "$1.*\.deb$" 2> /dev/null |

	while read SRC SERVERPATH
	do

		echo
		echo "SRC=$SRC" |
		highlight stable green |
		highlight testing yellow |
		highlight -bold unstable red
		echo "SERVERPATH=$SERVERPATH"
		echo

		SRC=`
			echo "$SRC" |
			/bin/sed '
				s+_+/+g
				s+/var/lib/apt/lists/++
				s+/dists/.*++
				# s+/debian/.*+/debian/+
				s+:Filename:$++
			'
		`

		## I can't find this in *Release or *Packages
		# URL="ftp://$SRC/$SERVERPATH"
		URL="http://$SRC/$SERVERPATH"

		echo "$URL"

	done

fi
