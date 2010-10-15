#!/bin/sh
# /usr/lib/xscreensaver/phosphor -font lucidatypewriter -delay 10 -scale 2 -geometry 1280x1024 -program "figletall joey@hwi.ath.cx"
TXTEXT=""
for FONTFILE in /usr/share/figlet/*.flf /stuff/mirrors/www.figlet.org/fonts/*.flf
do
	test "$*" || TXTEXT=`echo "$FONTFILE" | sed 's+.*/++;s+\.flf$++'`
	echo "$FONTFILE" | sed 's+.*/++;s+\.flf$++'
	figlet -f "$FONTFILE" "$@" "$TXTEXT"
done
