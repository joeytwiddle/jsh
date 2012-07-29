#!/bin/sh
# jsh-depends-ignore: wine winealldemoz
# jsh-depends: mykill waitforkeypress findjob curseblue curseyellow cursenorm
# jsh-ext-depends: find wine unzip

## I think I used to need this when I was running wine
xset fp- unix/:7101 2>/dev/null

curseyellow
echo
echo "==== UNZIPPING $1 ===="
echo
cursenorm

rm -rf /tmp/demotmp
mkdir -p /tmp/demotmp
cd /tmp/demotmp

unzip "$1" >/dev/null

echo
# ls -l -h
# echo

## Didn't really work (so should at least randomorder them!)
## Probably something was stealing and eating stdin!
## Ahhhh, the waitforkeypress!  TURNED OFF
## Oh, and probably the WineDbg console if it appears.  SOLVED WITH yes q
find . -iname "*.exe" | randomorder |
while read EXECUTABLE_FILE
do

## Of course this one doesn't like .exe's with spaces in their name:
# for EXECUTABLE_FILE in `find . -iname "*.exe"`
# do

	curseyellow
	echo
	echo "==== KILLING WINE ===="
	echo
	cursenorm

	## This is safer but the killall below should be used for certainty!
	echo | mykill -x "wine $EXECUTABLE_FILE"

	curseblue
	# (
		killall wine.bin wineserver wine-preloader
		rm -rf $HOME/.wine/wineserver-*
	# ) > /dev/null
	# Check it has been killed!
	sleep 1
	findjob wine |
	grep -v "$JPATH/tools/" |
	grep -v "winealldemoz" |
	grep -v "wineonedemo"
	cursenorm

	sleep 2



	filesize=`cat "$EXECUTABLE_FILE" | wc -c`
	if [ "$filesize" -gt 1024 ]
	then
		filesize=$((filesize / 1024))
		if [ "$filesize" -gt 1024 ]
		then
			filesize=$((filesize / 1024))
			filesize="$filesize Meg"
		else
			filesize="$filesize kilobytes"
		fi
	else
		filesize="$filesize bytes"
	fi

	# xttitle "`basename "$EXECUTABLE_FILE"` ($filesize) from $1"

	curseyellow
	echo
	echo "==== RUNNING $EXECUTABLE_FILE ($filesize) ===="
	echo
	cursenorm

	# To test for gl/non-gl progs:
	# -dll opengl32=s,n 
	# --managed 
	# --desktop 640x480+0+0 
	# export WINEPREFIX=$HOME/.wine_fake

	yes q | ## This quits the WineDbg console if it starts.

	# vsound -v -f /tmp/vsound.out.wav -d -t \
	# /usr/bin/wine "$EXECUTABLE_FILE"
	wine "$EXECUTABLE_FILE" 2>&1 | tee /tmp/wineonedemo.out

	exitCode=$?

	sleep 1

	# sleep 10
	# waitforkeypress

	[ "$exitCode" = 0 ] && break

	echo "Exit code: $?"

	if grep "DOS memory range unavailable" /tmp/wineonedemo.out >/dev/null
	then
		curseyellow
		echo
		echo "==== RETRYING $EXECUTABLE_FILE in DOSBox"
		echo
		cursenorm
		dosbox "$EXECUTABLE_FILE"
	fi

done

