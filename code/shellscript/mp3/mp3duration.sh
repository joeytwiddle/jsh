#!/bin/sh
## Output without the HACK below is usually 0-20 seconds below that reported by xmms.
## That is rather odd, since I would suspect this method to be
## slightly over, as it counts the tag data as taking up time as well.
## TODO: see if 1000 instead of 1024 fixes this.

## Different definition from jsh:
filesize () {
	find "$1" -follow -printf "%s\n"
}

if [ "$1" = -seconds ]
then
	INSECONDS=true
	shift
fi

TOTAL=0

for MP3
do

	if which mp3info >/dev/null 2>&1
	then

		## Eh this looks like rubbish:
		# SECONDS=`mp3info -x "$MP3" | grep "^Length" | sed 's+[^ ]*[ ]*++;s+:.*++'`
		SECONDS=`mp3info -p "%S" "$MP3"`

	else

		## Using file to determine bitrate does not work if mp3 doesn't have valid headers,
		## eg. a dumped mp3 portion of a streamed radio station.

		kBitsPerSec=`file -L "$MP3" | grep ' kBit/s' | beforelast ' kBit/s' | afterlast ', '`
		numBytes=`filesize "$MP3"`

		# debug "quality ($kBitsPerSec) size ($numBytes) from $MP3"

		if [ ! "$kBitsPerSec" ]
		then
			jshinfo "Failed to get quality from $MP3 ($kBitsPerSec), assuming 128."
			kBitsPerSec=128
		fi

		## Never happens, filesize works innit!
		# if [ ! "$kBitsPerSec" ] || [ ! "$numBytes" ]
		# then
			# jshinfo "Failed to get quality ($kBitsPerSec) or size ($numBytes) from $MP3"
			# continue
		# fi

		bytesPerSec=`expr $kBitsPerSec '*' 1024 / 8` || continue
		SECONDS=`expr $numBytes / $bytesPerSec` || continue
		## HACK
		SECONDS=`expr $SECONDS + 10`

	fi

	TOTAL=`expr $TOTAL + $SECONDS`
	if [ "$INSECONDS" ]
	then DURATION="$SECONDS"
	else
		minutes=`expr $SECONDS / 60`
		secondsToNearestMinute=`expr $minutes '*' 60`
		secondsLeft=`expr $SECONDS - $secondsToNearestMinute`
		# DURATION="$minutes:$secondsLeft"
		# DURATION="$minutes"m"$secondsLeft"s
		DURATION="$minutes"mins":$secondsLeft"s
	fi

	echo "$DURATION	$MP3"

done

if [ "$2" ]
then
	echo "Total: $TOTAL seconds"
	TOTMINS=`expr $TOTAL / 60`
	echo "  >= $TOTMINS minutes"
fi
