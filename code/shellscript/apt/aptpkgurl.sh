## Not working for security.debian.org (they have strange paths)

# grep "$1.*\.deb$" /var/lib/apt/lists/* 2> /dev/null |

memo grep "^Filename: " /var/lib/apt/lists/* |
grep "$1.*\.deb$" 2> /dev/null |

while read SRC PATH
do

	echo
	echo "SRC=$SRC"
	echo "PATH=$PATH"
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

	URL="ftp://$SRC/$PATH"

	echo "$URL"

done
