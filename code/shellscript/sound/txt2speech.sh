## WISHLIST: Rather than buffering by line, it'd be nice to read all available, then send to txt2speech, then read again...

## Don't wait for whole block, speak each line as it arrives:

if test "$1" = "-nobuf"
then

	while read LINE
	do
		echo "$LINE"
		echo "$LINE" | txt2speech
	done
	exit

fi

## Wait for whole block:

(

	echo "("

	## Can't
	# cat "$@" |
	## because options may be passed for later.  Cld fix by parsing options first yawn zzz
	cat |

	col -bx |
	# tr -s "\n" |

	## For IRC logs:
	# sed 's+\[\(..\):\(..\)\] <\([^>]*\)>+At \1 \2 user \3 said +' |
	sed "s+\[\(..\):\(..\)\] <\([^>]*\)>+ . \\
\3 says +" |

	## For tail:
	sed 's+^==> \(.*\) <==$+Appended to file \1:+' |

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
/stuff/install/cdrip/bladeenc -MONO -DELETE -QUIT /tmp/festival-out.wav
mv /tmp/festival-out.mp3 /tmp/tts.mp3

else

festival --tts

fi
