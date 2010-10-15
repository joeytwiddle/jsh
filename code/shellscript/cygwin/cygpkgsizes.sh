#!/bin/sh
cd /

'ls' /etc/setup/*.lst.gz | sed 's+^/etc/setup/++;s+\.lst\.gz$++' |

# cygcheck -c | takecols 1 | drop 2 | # chop 2 |

while read PKG
do
	printf "$PKG	"
	gunzip -c /etc/setup/$PKG.lst.gz 2> /dev/null |
	grep -v '/$' |
	# while read FILE
	# do
		# if test -f "$FILE" 2> /dev/null; then
			# echo "$FILE"
		# fi
	# done |
	xargs du -S |
	takecols 1 |
	awksum
done
