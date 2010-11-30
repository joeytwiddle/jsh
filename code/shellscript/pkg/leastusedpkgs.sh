#!/bin/sh

## For now:
listinstalledpackages () {
	env COLUMNS=65535 dpkg -l | fromline "[^D|+]" | takecols 2
}
listfilesinpackage () {
	dpkg -L "$1"
}

listinstalledpackages |
if [ "$1" ]
then grep "$@"
else cat
fi |
while read PKG
do

	## Select most recently accessed file from package
	LASTFILELINE=`
		listfilesinpackage "$PKG" |
		filesonly |
		# withalldo ls -aultr --time-style="+%s" |
		foreachdo ls -altr --time=use --time-style="+%s" |
		# pipeboth |
		tail -n 1 ## most recently accessed file
		# head -n 1 ## oldest accessed file
	`

	FILE=` printf "%s" "$LASTFILELINE" | takecols 7`
	if [ ! "$FILE" ]
	then
		jshinfo "Nothing for: $PKG"
	else
		LASTACCESSEDSECONDS=`
			echo "$LASTFILELINE" |
			takecols 6
		`
		LASTACCESSEDREADABLE=` date -d "1 January 1970 GMT + $LASTACCESSEDSECONDS seconds"`
		# echo "$PKG:	$LASTACCESSEDSECONDS	($LASTACCESSEDREADABLE)	$FILE" | pipeboth
		printf "%-18s %10s %s %s\n" "$PKG:" "$LASTACCESSEDSECONDS" "($LASTACCESSEDREADABLE)" "$FILE" | pipeboth
	fi

done |
sort -n -k 2 |
columnise
