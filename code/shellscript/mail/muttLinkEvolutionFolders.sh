echo "## Purge old:"
find $HOME/Mail -maxdepth 1 -type l -name "\|*" |
sed 's+^+rm "+;s+$+"+'

echo

echo "## Link new:"
find $HOME/evolution/local/ -name "mbox" |
while read X; do
	Y=`
		echo "$X" |
		tr " " "_" |
		sed "s+^$HOME/evolution/local++" |
		sed "s+/mbox$++" |
		sed "s+/subfolders/+|+g" |
		# sed "s+\(.*\)/\(.*\)$+\1|\2+" |
		# sed 's+/+|+g' |
		sed "s+^ ++"
		# sed 's+^|+\\\\+'
	`
	echo "ln -s \"$X\" \"$HOME/Mail/$Y\""
	# ln -s "$X" "./$Y"
done
