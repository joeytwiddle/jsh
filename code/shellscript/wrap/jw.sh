#!/bin/sh
## Sorts output of w by idle time.
## Rename: /usr/bin/jw is part of docbook-utils

duration2nanoseconds () {
	## Hacks to turn w's IDLEtime output into date/English
	DURATION=`
		echo "$1" |
		sed '
			s+:\(..\)m+ hours \1 minutes+
			s+\(.*\)\.\(..\)s+\1 seconds+
			s+\(.*\):\(..\)+\1 minutes \2 seconds+
		'
	`
	# echo "=$DURATION=" >&2
	NOW=`date +%s -d now`
	THEN=`date +%s -d "$DURATION ago"`
	# echo "now = $NOW, then = $THEN" >&2
	expr $NOW - $THEN
}

w |

(

	read LINE; echo "$LINE"

	(

		read LINE; echo "$LINE"

		while read USER TTY FROM LOGIN IDLE JCPU PCPU WHAT
		do

			# echo ">$IDLE<"
			SECONDS=`duration2nanoseconds $IDLE`
			# echo "+$SECONDS+"
			echo "$USER $TTY $FROM $LOGIN $SECONDS $IDLE $JCPU $PCPU $WHAT"

		done |

		sort -n -k 5 -r |

		dropcols 5

	) | columnise -upto 8

)
