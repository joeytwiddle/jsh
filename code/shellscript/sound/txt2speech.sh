#!/bin/sh
## WISHLIST: Rather than buffering by line, it'd be nice to read all available, then send to txt2speech, then read again...

## Don't wait for whole block, speak each line as it arrives:

if test "$1" = "-nobuf"
then

	shift
	while read LINE
	do
		echo "$LINE"
		echo "$LINE" | txt2speech
	done
	exit

fi

if [ "$1" = -join ]
then JOIN_LINES=true; shift
fi

NL="
"

## Wait for whole block:

(

	## Switch to the English(GB) voice if it is available:
	voiceDir="/usr/share/festival/voices/"
	[ -d "$voiceDir"/english/rab_diphone ] && echo "(voice_rab_diphone)"

	# echo "("

	## Can't
	# cat "$@" |
	## because options may be passed for later.  Cld fix by parsing options first yawn zzz
	cat |

	col -bx |
	# tr -s "\n" |

	## For IRC logs:
	## NOTE: Should try to work on live pasted chat as well as on logs!
	# sed 's+\[\(..\):\(..\)\] <\([^>]*\)>+At \1 \2 user \3 said +' |
	sed "s+\[\(..\):\(..\)\] <\([^>]*\)>+ . \n \3 says +" |
	## For pasted IRC channels:
	sed "s+<\([^>]*\)>+ . \n \1 - . - +" |
	grep -v "\-\->.* has joined #" |
	grep -v "<\-\-.* has left #" |
	grep -v "<\-\-.* has quit (" |
	## TODO: Should go into seperate script irc2speech
	## See also: irc_radio.sh in xchat log folder

	## For tail:
	sed 's+^==> \(.*\) <==$+Appended to file \1:+' |

	## for debugging:
	# tee /tmp/tmp-tts.txt |	

	## Festival already handles dashes with a brief pause, if they are surrounded by spaces (not a hyphen directly between two words)
	# sed "s/--/, /g" |
	# sed "s/-/ dash /g" |
	# sed "s/-/ /g" |
	# sed "s/\./ dot /g" |
	# sed "s/^$/\\
	## But two words joined by a dash are pronounced awfully (festival reads the letters!), so:
	sed 's/-/ - /g' |
# . new paragraph.\\
# /" |
	# tr "\n" " " |
	# sed "s|\(\. new paragraph\.\)|\1\\
# |g" |
	if [ "$JOIN_LINES" ]
	then
		sed "s/^$/NEW_PARAGRAPH/" |
		tr "\n" " " |
		sed "s/NEW_PARAGRAPH/\\
/g"
	else
		# sed 's+^$+.'"$NL"'+ ; s+$+;+'
		sed 's+.$+\0.+ ; s/^$/ : : '"\\$NL . : . \\$NL"/
		# cat
	fi |
	sed "s/\%/ percent /g" |
	sed "s/\?/./g" |
	sed "s/^ /\\
/" |
	# sed 's|\"\([^"]*\)\"| quote \1 unquote |g' |
	# # sed 's|(\([^)]*\))| open-bracket \1 close-bracket |g' |
	# sed 's|(| open-bracket |g' |
	# sed 's|)| close-bracket |g' |
	# sed 's|\"| unmatched-quote |g' |
	## Do not speak brackets or colons, but slow down on them
	sed 's|[():]| \n . : . |g' |
	tr -d '"' |

	## Remove [12] citations from wikipedia pages
	sed 's|\[[0-9]*\]||g' |
	sed 's|\[edit\]||g' |

	sed 's|\<US\>|U S|g' |
	# sed 's|\<of\>|orve|g' |

	sed 's+^+(SayText "+ ; s+$+")+' |
	cat

	# echo ")"

) |

pipeboth |

if test "$1" = "-tomp3"
then

## Output a wav (in a format suitable for bladeenc)
text2wave -F 48000 -otype riff -o /tmp/festival-out.wav
/stuff/install/cdrip/bladeenc -MONO -DELETE -QUIT /tmp/festival-out.wav
mv /tmp/festival-out.mp3 /tmp/tts.mp3

else

festival # --tts

fi
