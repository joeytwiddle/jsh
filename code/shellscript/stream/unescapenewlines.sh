#!/bin/sh
# jsh-ext-depends: sed
# jsh-depends-ignore: escapenewlines error

# unj decodeslashn "$@"

## In fact, for decoding a newline-escaped stream, tr -d '\n' should never be harmful, so the -x option needn't really be specified, it could be assumed.  (But if it is going to be sent, the -x should be caught!)

if [ "$1" = -test ]
then

	NL='
'

	testescaping () {
		RESA=`echo "$X"`
		INTER=`echo "$X" | escapenewlines`
		RESB=`echo "$X" | escapenewlines | unescapenewlines`
		echo -n "input  = >"
		echo -n "$RESA"
		echo "<"
		# echo -n "inter  = >"
		# echo -n "$INTER"
		# echo "<"
		echo -n "output = >"
		echo -n "$RESB"
		echo "<"
		if [ ! "$RESA" = "$RESB" ]
		then error "not equal!"
		else echo "ok =)"
		fi
		echo
	}

	for X in "\n$NL\n" "$NL" "$NL$NL" "\n" "\\n" "\\\n" "\\\\n" "\\\\\n" "\\$NL"n "\\$NL\n" "\\\\$NL\n"
	do testescaping
	done

	exit

fi

CONTRACT_WORDS=
if test "$1" = -x
then shift; CONTRACT_WORDS=true
fi

cat "$@" |

if test "$CONTRACT_WORDS"
then tr -d '\n'
else cat
fi |

# unj unescapenewlines

# exit

# Not entirely working because not parsed concurrently:
# Would be OK to match (\\n|\\\\) if we could do different things when we replace
# TRY: \(\\\(n\)\|\\\(\\\)\) -> \2\3
# oh but we want \n instead of \2 :-(
# sed 's+\\n+\
# +g;s+\\\\+\\+g'

## Inelegant fudge:
## Turns '\''\'  into $UNIQUE (to get them out of the way without affecting the '\''\n's),
##  then '\''n'  into '\n',
##  then $UNIQUE into '\'.
(
UNIQUE="#slash1#unique_jadljfofjw90f02""4329r2934SFKSLFSL""skxc8DJknk4lkkk09""DkSPlerA3428Kasd298jh_unique#slash2#"
sed 's+\\\\+'"$UNIQUE"'+g;s+\\n+\
+g;s+'"$UNIQUE"'+\\+g'
)
