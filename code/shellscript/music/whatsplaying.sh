# tail -1 $JPATH/logs/xmms.log | afterlast ">" | beforelast "<"

PROGNAME=`fuser -v /dev/dsp | drop 2 | head -n 1 | takecols 5`

if [ ! "$PROGNAME" ]
then
	echo "Could not find any process accessing /dev/dsp"
	exit 1
fi

/usr/sbin/lsof -c "$PROGNAME" |

	## Negative match: (could be confirmed later eg. by file)
	# grep -v /lib/ |
	# grep -v "\(/tmp\|/dev/null\|/usr/bin/xmms\|/dev/dsp.\|/dev/pts.\|/dev/pts..\|pipe\|socket\|/\|/tmp/xmms_[^ ]*\)$" |

	## Positive match:
	grep -i '\.\(mp3\|ogg\|avi\|mov\|bin\|wav\|pcm\|raw\|mpg\|mpeg\|rm\|wmv\)$' |

	# pipeboth |

	dropcols 1 2 3 4 5 6 7 8 |
	removeduplicatelines

