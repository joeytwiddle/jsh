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

	kBitsPerSec=`file -L "$MP3" | grep ' kBit/s' | beforelast ' kBit/s' | afterlast ', '`
	numBytes=`filesize "$MP3"`

	# debug "quality ($kBitsPerSec) size ($numBytes) from $MP3"

	if [ ! "$kBitsPerSec" ]
	then
		error "Problem getting quality ($kBitsPerSec) from $MP3, guessing 128"
		kBitsPerSec=128
	fi
		

	if [ ! "$kBitsPerSec" ] || [ ! "$numBytes" ]
	then
		error "Problem getting quality ($kBitsPerSec) or size ($numBytes) from $MP3"
		continue
	fi

	bytesPerSec=`expr $kBitsPerSec '*' 1024 / 8` || continue
	secondsTotal=`expr $numBytes / $bytesPerSec` || continue
	## HACK
	secondsTotal=`expr $secondsTotal + 10`
	TOTAL=`expr $TOTAL + $secondsTotal`
	if [ "$INSECONDS" ]
	then RESULT="$secondsTotal"
	else
		minutes=`expr $secondsTotal / 60`
		secondsToNearestMinute=`expr $minutes '*' 60`
		secondsLeft=`expr $secondsTotal - $secondsToNearestMinute`
		# RESULT="$minutes:$secondsLeft"
		RESULT="$minutes"m"$secondsLeft"s
	fi

	echo "$RESULT	$MP3"

done

if [ "$2" ]
then
	echo "Total: $TOTAL seconds"
	TOTMINS=`expr $TOTAL / 60`
	echo "  >= $TOTMINS minutes"
fi
