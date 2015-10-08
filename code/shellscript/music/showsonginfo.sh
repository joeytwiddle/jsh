#!/bin/bash

PRE=""
NL="
"
for FILE
do

	# FILE="`realpath "$FILE"`"
	FILE="`realpath "$FILE" | sed 's+^/mnt/[^/]*/stuff/+/stuff/+'`"
	DIR=`dirname "$FILE"`

	FILENAME=`basename "$FILE"`

	NAME=
	TIME=
	YEAR=
	COMMENT=
	## Get mp3info from the file, or fallback data.
	if echo "$FILE" | grep -i "\.mp3$" >/dev/null && which mp3info >/dev/null 2>&1
	then
		## Note that mp3info will send error messages to stderr if tags cannot be
		## read from the file.
		NAME=$( mp3info -p "%a - %l - %t" "$FILE" )
		[ "$NAME" = " -  - " ] && NAME=
		TIME=$( mp3info -p "%mm%ss" "$FILE" )
		YEAR=$( mp3info -p "%y" "$FILE" )
		COMMENT=$( mp3info -p "%c" "$FILE" )
	elif echo "$FILE" | grep -i "\.ogg$" >/dev/null && which ogginfo >/dev/null 2>&1
	then
		NAME=$( ogginfo "$FILE" | grep "^[ 	]*TITLE=" | head -n 1 | sed 's/^[^=]*=//')
		TIME=$( ogginfo "$FILE" | grep "^[ 	]*TIME=" | head -n 1 | sed 's/^[^=]*=//')
		YEAR=$( ogginfo "$FILE" | grep "^[ 	]*DATE=" | head -n 1 | sed 's/^[^=]*=//')
		COMMENT=$( ogginfo "$FILE" | grep "^[ 	]*COMMENT=" | head -n 1 | sed 's/^[^=]*=//')
	fi

	## Fallback:
	[ -n "$NAME" ] || NAME=""

	[ -n "$TIME" ] && TIME="$NL  Length: $TIME"

	[ -n "$YEAR" ] && YEAR="  Year: $YEAR"
	[ -n "$COMMENT" ] && COMMENT="$NL  Comment: $COMMENT"

	## CONSIDER TODO: Use getvideoduration instead?
	[ "$TIME" ] || TIME="$NL  $( filesize "$FILE" | rev | sed 's+...+\0,+g ; s+^,++' | rev ) bytes"

	## Lookup amarok info for the file
	if which amaroklookup
	then
		AMAROK_DATA=$( amaroklookup "$FILE" | grep -v ^/ | sed 's+^\(.\)+  \1+' )
		[ "$AMAROK_DATA" ] && AMAROK_DATA="$NL$AMAROK_DATA"
		# echo "$DIR:
		# $NAME
	fi

	OUTPUT="${PRE}${FILENAME} ${NAME}${TIME}${YEAR}${COMMENT}${AMAROK_DATA}${NL}  Path: ${DIR}/"
	echo "$OUTPUT"

	## Display this output as a screen overlay, using osd_cat
	## Try to background the rendering, so this script return to its caller soon.
	(

		# FONT='-*-freesans-*-r-*-*-*-240-*-*-*-*-*-*'
		# FONT='-*-lucidabright-medium-r-*-*-26-*-*-*-*-*-*-*'
		# FONT='-*-helvetica-*-r-*-*-*-240-*-*-*-*-*-*'
		# FONT='-*-dusty-*-*-*-*-40-*-*-*-*-*-*-*'
		# FONT='-*-london tube-*-*-*-*-*-300-*-*-*-*-*-*'
		# FONT='-*-koshgarian ligh-*-*-*-*-*-300-*-*-*-*-*-*'
		# FONT='-*-robotic monkey-*-r-*-*-*-300-*-*-*-*-*-*'
		## Can't get eurostile in bold from xfstt.  :f
		# FONT='-*-eurostile-*-*-*-*-45-*-*-*-*-*-*-*'
		# smallerFONT='-*-eurostile-*-*-*-*-35-*-*-*-*-*-*-*'
		## Now I can't get minima either!!
		# FONT='-*-minima ssi-bold-*-*-*-*-340-*-*-*-*-*-*'
		# smallerFONT='-*-minima ssi-bold-*-*-*-*-240-*-*-*-*-*-*'
		# FONT='-*-microgrammadmedext-*-*-*-*-40-*-*-*-*-*-*-*'
		# smallerFONT='-*-microgrammadmedext-*-*-*-*-30-*-*-*-*-*-*-*'
		# FONT='-*-microgrammadmedext-*-*-*-*-44-*-*-*-*-*-*-*'
		# smallerFONT='-*-microgrammadmedext-*-*-*-*-34-*-*-*-*-*-*-*'
		## Heavy/Bold version:
		# FONT='-*-microgrammadbolext-*-*-*-*-44-*-*-*-*-*-*-*'
		# smallerFONT='-*-microgrammadbolext-*-*-*-*-34-*-*-*-*-*-*-*'
		## I get Terminus at least, which defaults to bold, but doesn't go over 320.
		FONT='-*-*-*-r-*-*-*-320-*-*-*-*-*-*'
		smallerFONT='-*-*-*-r-*-*-*-280-*-*-*-*-*-*'

		[ "$smallerFONT" ] || smallerFONT="$FONT"

		killall osd_cat 2>&1 | grep -v "^osd_cat: no process \(killed\|found\)$"

		killall osd_cat 2>&1 | grep -v "^osd_cat: no process \(killed\|found\)$"
		# ` mp3info "$FILE" 2>/dev/null `" |
		# osd_cat -c orange -f '-*-lucida-*-r-*-*-*-220-*-*-*-*-*-*'
		# for COL in black green yellow red magenta blue cyan green black
		# for COL in white red green blue black
		for COL in green # magenta red blue yellow
		do
			# echo "$OUTPUT" | osd_cat -c "$COL" -d 8 -s 2 -f "$FONT"
			echo "$OUTPUT" | head -n 1 | osd_cat -c "$COL" -i 8 -o 12 -d 7 -O 3 -f "$FONT" &
			sleep 0.5
			echo "$OUTPUT" | drop 1 | osd_cat -c "$COL" -i 16 -o 64 -d 7 -O 3 -f "$smallerFONT" &
			wait
			PRE="$PRE$NL$NL"
		done
	) &

done

