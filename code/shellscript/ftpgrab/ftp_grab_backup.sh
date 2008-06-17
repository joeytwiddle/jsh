## BUGS: On one server some text files appeared as 2 or 4 bytes longer remotely than the file we received locally, so these were always repeat-fetched. :|

function convert_ftp_response_to_filestats() {
	(
		echo "./$1:"
		cat "$2" | fromline "^[d-]"
	) | ls-Rtofilelist -l
}

# ftp://user@host.blah/folder/s

SEARCH_FOLDERS_FOR_MATCH="/mnt/big/ut/ut_win /mnt/big/ut/files"
HOST="$1"
USERNAME="$2"
PASSWORD="$3"
REMOTEFOLDER="$4"

if [ "$REMOTEFOLDER" == "" ]
then
	echo "ftp_grab_backup <host> <user> <pass> <remotedir>"
	echo "  will make a copy of specified directory in current directory"
	echo "  If matching files are available in SEARCH_FOLDERS_FOR_MATCH then sylinks will be created to the matches rather than a copy of the file being created locally."
	exit 0
fi

FILELIST=filelist-"$HOST-`echo "$REMOTEFOLDER" | tr / _`" # .`geekdate -fine`"

# echo "ls -l -R $REMOTEFOLDER" |
# ncftp -u "$USERNAME" -p "$PASSWORD" "$HOST" |
# cat > "$FILELIST".ncftp

TARGET_DIR="$PWD"

convert_ftp_response_to_filestats "$REMOTEFOLDER" "$FILELIST".ncftp |
# tee "$FILELIST".fixed |
grep "^-" > "$FILELIST"


function download_file() {
	verbosely wget -nv --user="$USERNAME" --password="$PASSWORD" "ftp://$HOST/$1" -O - > "$2"
}

cat "$FILELIST" |

while read PERMS NODE OWNER GROUP SIZE DATEMON DATEDAY DATEYEAR FILEPATH
do

	# jshinfo "$FILEPATH ($SIZE) $DATEMON $DATEDAY $DATEYEAR"

	## Do we already have this file?

	if [ -e "$TARGET_DIR/$FILEPATH" ]
	then
		# jshinfo "Already got: $TARGET_DIR/$FILEPATH"
		## Check size is correct
		LOCAL_FILE_SIZE=`filesize "$TARGET_DIR/$FILEPATH"`
		if [ ! "$LOCAL_FILE_SIZE" = "$SIZE" ]
		then
			jshwarn "$TARGET_DIR/$FILEPATH size $LOCAL_FILE_SIZE != $SIZE"
			verbosely del "$TARGET_DIR/$FILEPATH"
			download_file "$FILEPATH" "$TARGET_DIR/$FILEPATH"
		fi
		continue
	fi

	## Can we find a file on the system which matches?

	if [ "$SEARCH_FOLDERS_FOR_MATCH" ]
	then
		FILENAME=`echo "$FILEPATH" | afterlast /`
		FILENAMEREGEXP=`toregexp "$FILENAME"`
		find $SEARCH_FOLDERS_FOR_MATCH -type f | grep -i "/$FILENAMEREGEXP$" |
		while read FILE
		do
			if [ "`filesize "$FILE"`" = "$SIZE" ]
			then
					jshinfo "We can use: $FILE for $FILEPATH"
					mkdir -p "`dirname "$TARGET_DIR/$FILEPATH"`"
					( [ -f "$TARGET_DIR/$FILEPATH" ] || [ -L "$TARGET_DIR/$FILEPATH" ] ) && verbosely del "$TARGET_DIR/$FILEPATH"
					verbosely ln -s "$FILE" "$TARGET_DIR/$FILEPATH"
					echo "OK: $FILE" ## for the grep . later
					break ## kill the find; since we don't need it anymore
			else
				jshinfo "We cannot use: $FILE for $FILEPATH"
				:
			fi
		done | grep . >/dev/null && continue
	fi

	if [ ! "$?" = 0 ] && [ ! -f "$TARGET_DIR/$FILEPATH" ] && [ ! -L "$TARGET_DIR/$FILEPATH" ] ## added extra checks 'cos i kept breaking the echo/grep
	then
		## TODO: optionally recycle (check-in) old file if it exists (we could check that it's not just a partial d/l)
		jshwarn "No suitable candidate for $FILEPATH"
		mkdir -p "`dirname "$TARGET_DIR/$FILEPATH"`" &&
		cd "$TARGET_DIR" &&
		download_file "$FILEPATH" "$TARGET_DIR/$FILEPATH"
	fi

done

