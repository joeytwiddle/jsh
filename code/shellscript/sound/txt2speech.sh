(
	col -bx |
	# tr -s "\n" |
	sed "s/--/, /g" |
	sed "s/-/ dash /g" |
	# sed "s/\./ dot /g" |
	# sed "s/^$/\\
# . new paragraph.\\
# /" |
	# tr "\n" " " |
	# sed "s|\(\. new paragraph\.\)|\1\\
# |g" |
	sed "s/^$/NEW_PARAGRAPH/" |
	tr "\n" " " |
	sed "s/NEW_PARAGRAPH/\\
/g" |
	sed "s/\%/ percent /g" |
	sed "s/\?/./g" | tee hello.txt |
	sed "s/^ /\\
/" |
	sed 's|\"\([^"]*\)\"| quote \1 unquote |g' |
	# sed 's|(\([^)]*\))| open-bracket \1 close-bracket |g' |
	sed 's|(| open-bracket |g' |
	sed 's|)| close-bracket |g' |
	sed 's|\"| unmatched-quote |g'
) |

while read LINE
do

	echo "$LINE"
	(
		echo '("'
		echo "$LINE"
		echo '")'
	) | festival --tts

done
