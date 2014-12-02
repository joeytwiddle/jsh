# vorbiscomment is from vorbis-tools package
# lltag (not used here) is a single interface for various filetypes

for file in "$@"
do
	fname=`basename "$file" | beforelast '\.'`

	artist=`echo "$fname" | beforefirst '-' | trimstring`
	if [ "$artist" = "$fname" ]
	then artist=""   # There was no -
	fi
	album=`echo "$fname" | afterfirst '-' | beforefirst '-' | trimstring`
	title=`echo "$fname" | afterlast '-' | trimstring`

	if [ "$album" = "$title" ]
	then album=""
	fi

	extension=`echo "$file" | afterlast '\.'`

	if [ -z "$artist" ] || [ -z "$title" ]
	then
		echo
		echo "Not enough info found for: $file"
		echo "Filename: $fname"
		echo "Artist:   $artist"
		echo "Album:    $album"
		echo "Track:    $title"
		echo "You can try yourself:"
		if [ "$extension" = mp3 ]
		then echo "mp3info -a \"\" -t \"\" \"$file\""
		elif [ "$extension" = ogg ]
		then echo "vorbiscomment -w -t ARTIST=\"\" -t ALBUM=\"\" -t TITLE=\"\" \"$file\""
		fi
		echo
		continue
	fi >&2

	if [ "$extension" = mp3 ]
	then
		if [ -n "$album" ]
		then set_album=" -l \"$album\""
		else set_album=""
		fi
		# Track number: -n 5
		echo "mp3info -a \"$artist\"$set_album -t \"$title\" \"$file\""
	elif [ "$extension" = ogg ]
	then
		if [ -n "$album" ]
		then set_album=" -t \"ALBUM=$album\""
		else set_album=""
		fi
		# TRACKNUMBER
		echo "vorbiscomment -w -t ARTIST=\"$artist\"$set_album -t TITLE=\"$title\" \"$file\""
	else
		echo "I do not know how to tag a file with extension \"$extension\"" >&2
	fi

done
