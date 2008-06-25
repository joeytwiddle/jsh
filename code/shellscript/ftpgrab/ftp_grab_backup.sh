## BUGS: On one server some text files appeared as 2 or 4 bytes longer remotely than the file we received locally, so these were always repeat-fetched. :|

function convert_ftp_response_to_filestats() {
	(
		echo "./$1:"
		cat "$2" | fromline "^[d-]"
	) | ls-Rtofilelist -l
}

# ftp://user@host.blah/folder/s

SEARCH_FOLDERS_FOR_MATCH="/mnt/big/ut/ut_win /mnt/big/ut/files"
REMOTEHOST="$1"
USERNAME="$2"
PASSWORD="$3"
REMOTEFOLDER="$4"
KEEP_OLD_VERSIONS=true
TARGET_DIR="$PWD" ## $REMOTEFOLDER/$FILEPATH gets appended to this
GEEKDATE="`hostname`.`geekdate`"

if [ "$REMOTEFOLDER" == "" ]
then
	echo "ftp_grab_backup <host> <user> <pass> <remotedir>"
	echo "  will make a copy of specified directory in current directory (due to implementation, the remote path is preserved locally)"
	echo "  If a file with matching name and size is available in SEARCH_FOLDERS_FOR_MATCH then a sylink will be created to that file rather than a copy of the file being created locally."
	echo "  If KEEP_OLD_VERSIONS is set, then out-of-date local files will be renamed to <file>.$GEEKDATE instead of being overwritten."
	echo "  IGNORES symlinks in the remote location."
	exit 0
fi

FILELIST=filelist-"$REMOTEHOST-`echo "$REMOTEFOLDER" | tr / _`.`geekdate`"

jshinfo "Getting remote file list..."
echo "ls -l -R $REMOTEFOLDER" |
verbosely ncftp -u "$USERNAME" -p "$PASSWORD" "$REMOTEHOST" |
# ssh "$USERNAME"@"$REMOTEHOST" "ls -l -R $REMOTEFOLDER" |
cat > "$FILELIST".ncftp

jshinfo "Converting to tree list..."
convert_ftp_response_to_filestats "$REMOTEFOLDER" "$FILELIST".ncftp |
# tee "$FILELIST".fixed |
if [ "$IGNORE_REGEXP" ]
then grep -v "$IGNORE_REGEXP"
else cat
fi |
grep "^-" > "$FILELIST"

function download_file() {
	verbosely wget -nv --user="$USERNAME" --password="$PASSWORD" "ftp://$REMOTEHOST/$1" -O - > "$2"
}

function recycle() {
	if [ "$KEEP_OLD_VERSIONS" ]
	then verbosely mv "$1" "$1".$GEEKDATE
	else del "$1"
	fi
}

jshinfo "Scanning for new/changed files..."

cat "$FILELIST" |

while read PERMS NODE OWNER GROUP SIZE DATEMON DATEDAY DATEYEAR FILEPATH
do

	# jshinfo "$FILEPATH ($SIZE) $DATEMON $DATEDAY $DATEYEAR"

	## Do we already have this file?

	if [ -e "$TARGET_DIR/$FILEPATH" ] || [ -f "$TARGET_DIR/$FILEPATH" ] || [ -L "$TARGET_DIR/$FILEPATH" ]
	then
		# jshinfo "Already got: $TARGET_DIR/$FILEPATH"
		## Check size is correct
		LOCAL_FILE_SIZE=`filesize "$TARGET_DIR/$FILEPATH"` ## find size of symlink contents, not link size
		if [ "$LOCAL_FILE_SIZE" = "$SIZE" ]
		then
			# jshinfo "Matches: $TARGET_DIR/$FILEPATH"
			continue
			# jshwarn "$TARGET_DIR/$FILEPATH size $LOCAL_FILE_SIZE != $SIZE"
			# verbosely del "$TARGET_DIR/$FILEPATH"
			# download_file "$FILEPATH" "$TARGET_DIR/$FILEPATH"
		else
			jshinfo "Local copy mismatches: $TARGET_DIR/$FILEPATH"
			recycle "$TARGET_DIR/$FILEPATH"
		fi
		# continue
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
					( [ -f "$TARGET_DIR/$FILEPATH" ] || [ -L "$TARGET_DIR/$FILEPATH" ] ) && recycle "$TARGET_DIR/$FILEPATH"
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

if [ "$KEEP_OLD_VERSIONS" ]
then jshinfo "Old versions were saved as <file>.$GEEKDATE"
fi

