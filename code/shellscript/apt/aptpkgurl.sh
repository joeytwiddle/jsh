## Not working for security.debian.org (they have strange paths)

# grep "$1.*\.deb$" /var/lib/apt/lists/* 2> /dev/null |

memo grep "^Filename: " /var/lib/apt/lists/* |
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

	URL="ftp://$SRC/$SERVERPATH"

	echo "$URL"

done
