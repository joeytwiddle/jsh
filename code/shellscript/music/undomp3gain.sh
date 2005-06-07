# jsh-depends: qkcksum error
for FILE
do
	# mp3gain -u "$FILE"
	# mp3gain -s d "$FILE"
	CHECK=`qkcksum "$FILE"`
	SHOULDBE=`cat "$FILE".qkcksum.b4mp3gain`
	if [ ! "$CHECK" = "$SHOULDBE" ]
	then
		error "Failed match:"
		error "CHECK    = $CHECK"
		error "SHOULDBE = $SHOULDBE"
	fi
done
