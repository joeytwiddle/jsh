#!/bin/bash

if test "$1" = ""; then
	echo "irclog2html <irc_log_file>"
	exit 1
fi

IRCUSERS=`
cat "$1" |
grep "<[^>]*>" |
sed "s|<\([^>]*\)>.*|\1|" |
keepduplicatelines
`

echo "$IRCUSERS"

export COLORS="red
green
blue
yellow
cyan
magenta
darkred
darkgreen
darkblue
darkyellow
darkcyan
darkmagenta"

SEDSTR='s|<|\&lt;|g ; s|>|\&gt;|g ; '

for IRCUSER in $IRCUSERS
do
	# COL=`expr 1 + \`hashstring "$IRCUSER"\` '%' 5`
	HCOL=`echo "$COLORS" | chooserandomline`
	SEDSTR="$SEDSTR s|$IRCUSER|<b><font color=\"$HCOL\">$IRCUSER</font></b>|g ;"
done
SEDSTR="$SEDSTR s|\$|<br>| ;"

cat "$1" | sed "$SEDSTR"
