## BUG: doesn't work if you use a sound server (eg. artsd or esd).  Fixing that would probably require a different approach.

# tail -n 1 $JPATH/logs/xmms.log | afterlast ">" | beforelast "<"

FILES=`

	for DEV in /dev/dsp /dev/sound/dsp
	do [ -e $DEV ] && fuser -v $DEV 2>&1
	done |
	drop 2 |
	# takecols 5 |
	dropcols 1 2 3 4 | ## only the first line has something in first column, so this works better
	removeduplicatelines |
	trimempty |

	while read PROGNAME
	do

		# jshinfo "$PROGNAME"

		/usr/sbin/lsof -c "$PROGNAME" |

		## Negative match: (could be confirmed later eg. by file)
		# grep -v /lib/ |
		# grep -v "\(/tmp\|/dev/null\|/usr/bin/xmms\|/dev/dsp.\|/dev/pts.\|/dev/pts..\|pipe\|socket\|/\|/tmp/xmms_[^ ]*\)$" |

		## Positive match:
		grep -i '\.\(mp3\|ogg\|avi\|mov\|wav\|pcm\|raw\|mpg\|mpeg\|rm\|wmv\|mod\|xm\)$' |

		# pipeboth |

		dropcols 1 2 3 4 5 6 7 8 |
		removeduplicatelines

	done

`

OUTPUT=`

	## For compatibility with randommp3 script:
	if ( [ "$FILES" = /tmp/randommp3-gainchange.mp3 ] || [ "$FILES" = /tmp/randommp3-gainchange-2.mp3 ] ) && [ -e "$FILES.whatsplaying" ]
	then
		jshinfo "[whatsplaying] Got back "$FILES" so reading $FILES.whatsplaying instead:"
		ls -l "$FILES.whatsplaying" | dropcols 1 2 3 4 5 6 7 8 9 10
	else
		echo "$FILES"
	fi |
	removeduplicatelines ## because, at least, mplayer opens the file in two threads/processes

`

echo "$OUTPUT"

echo "$OUTPUT" |
while read FILE
do
	DIR=`dirname "$FILE"`
	NAME=`basename "$FILE"`
(
echo "$DIR:
$NAME
`mp3info "$FILE"`" | osd_cat -c orange -f '-*-lucida-*-r-*-*-*-220-*-*-*-*-*-*'
) &
done

