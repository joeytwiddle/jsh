#!/bin/sh
## Attempts to calculate the "last-used" date of packages on your Debian system,
## by finding the most recently accessed file in each package.
## The output list has recently accessed packages last, unused packages first.
## CONSIDER: To speed up the process, we could check only /bin/ and /etc/ files.
## BUG: Tested briefly, conclusion: not 100% working!

COLUMNS=580 dpkg -l | grep "^ii" | takecols 2 | grep "$1" |
while read PKG
do
	MOST_RECENT=`
		dpkg -L "$PKG" | filesonly |
		while read FILE
		do find "$FILE" -maxdepth 0 -printf "%A@ %p\n"
		done | sort -n -k 1 | tail -n 1
	`
	echo "$PKG $MOST_RECENT"
done |

pipeboth --line-buffered |

sort -n -k 2 |

while read PACKAGE DATESECS FILE
do echo "`date -d "Jan 1 00:00:00 GMT 1970 + $DATESECS seconds"` $PACKAGE $FILE"
done

