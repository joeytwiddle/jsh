(

	echo "("

	cat |

	col -bx |
	# tr -s "\n" |

	## For IRC logs:
	# sed 's+\[\(..\):\(..\)\] <\([^>]*\)>+At \1 \2 user \3 said +' |
	sed "s+\[\(..\):\(..\)\] <\([^>]*\)>+ . \\
\3 says +" |

	## for debugging:
	# tee /tmp/tmp-tts.txt |	

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
	sed "s/\?/./g" |
	sed "s/^ /\\
/" |
	sed 's|\"\([^"]*\)\"| quote \1 unquote |g' |
	# sed 's|(\([^)]*\))| open-bracket \1 close-bracket |g' |
	sed 's|(| open-bracket |g' |
	sed 's|)| close-bracket |g' |
	sed 's|\"| unmatched-quote |g'

	echo ")"

) |

if test "$1" = "-tomp3"
then

## Output a wav (in a format suitable for bladeenc)
text2wave -F 48000 -otype riff -o /tmp/festival-out.wav
/mnt/pod8/joey/moreinstalls/cdrip/bladeenc -MONO -DELETE -QUIT /tmp/festival-out.wav
mv /tmp/festival-out.mp3 /tmp/tts.mp3

else

festival --tts

fi
