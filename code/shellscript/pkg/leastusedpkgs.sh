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
	# listfilesinpackage "$PKG"
	# continue
	LASTFILELINE=`
	listfilesinpackage "$PKG" |
	filesonly |
	# withalldo ls -aultr --time-style="+%s" |
	foreachdo ls -aultr --time-style="+%s" |
	# pipeboth |
	tail -1
	`
	LASTACCESSEDSECONDS=`
	echo "$LASTFILELINE" |
	takecols 6
	`
	FILE=` echo "$LASTFILELINE" | takecols 7`
	LASTACCESSEDREADABLE=` "1 January 1970 GMT + $LASTACCESSEDSECONDS seconds"`
	# echo "$PKG:	$LASTACCESSEDSECONDS	($LASTACCESSEDREADABLE)	$FILE" | pipeboth
	printf "%-18s %10s %s %s\n" "$PKG:" "$LASTACCESSEDSECONDS" "($LASTACCESSEDREADABLE)" "$FILE" | pipeboth
done |
sort -n -k 2 |
columnise
