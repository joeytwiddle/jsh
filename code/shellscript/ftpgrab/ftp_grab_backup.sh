
## BUGS: On one server some text files appeared as 2 or 4 bytes longer remotely than the file we received locally, so these were always repeat-fetched. :|

## TODO: sftp:// not yet working!  Here is output:
# [INFO] Scanning for new/changed files...
# [INFO] Local copy mismatches: /mnt/hdb6/kx_backup/./ut//
# [EXEC] % mv /mnt/hdb6/kx_backup/./ut// /mnt/hdb6/kx_backup/./ut//.20080625
# mv: cannot move `/mnt/hdb6/kx_backup/./ut//' to a subdirectory of itself, `/mnt/hdb6/kx_backup/./ut//.20080625'
# [WARN] No suitable candidate for ./ut//
# scp: ./ut: not a regular file
# touch: invalid date format `2008-07-01 20:47 added_bt_files.list'
# [INFO] Local copy mismatches: /mnt/hdb6/kx_backup/./ut//
# [EXEC] % mv /mnt/hdb6/kx_backup/./ut// /mnt/hdb6/kx_backup/./ut//.20080625
# mv: cannot move `/mnt/hdb6/kx_backup/./ut//' to a subdirectory of itself, `/mnt/hdb6/kx_backup/./ut//.20080625'
## Well it just about worked for XOL.  Check for regexp issues: e.g. -)AO(-hayloft.unn

function convert_ftp_response_to_filestats() {
	## TODO: This does not do what it should if "$1" starts with "/"
	(
		echo "$1:"
		cat "$2" | fromline "^[d-]"
	) | ls-Rtofilelist -l
}

if [[ "$1" =~ "^sftp://" ]]
then
	USE_SFTP=1
	SSH_USERHOST=`echo "$1" | sed 's+sftp://\([^/]*\)/.*+\1+'`
	REMOTEFOLDER=`echo "$1" | sed 's+sftp://[^/]*/\(.*\)+\1+'`
else
	## ftp:
	REMOTEHOST="$1"
	USERNAME="$2"
	PASSWORD="$3"
	REMOTEFOLDER="$4"
fi

KEEP_OLD_VERSIONS=true
TARGET_DIR="$PWD" ## $REMOTEFOLDER/$FILEPATH gets appended to this

if [ "$REMOTEFOLDER" == "" ]
then
	echo "ftp_grab_backup <host> <user> <pass> <remotedir>"
	echo "ftp_grab_backup sftp://<user>@<host>:<remotedir>"
	echo "  will make a copy of specified directory in current directory (due to implementation, the remote path is preserved locally)"
	echo "  If a file with matching name and size is available in SEARCH_FOLDERS_FOR_MATCH then a sylink will be created to that file rather than a copy of the file being created locally."
	echo "  If KEEP_OLD_VERSIONS is set, then out-of-date local files will be renamed to <file>.<date> instead of being overwritten."
	## TODO: Create "archive remote versions"(?) = keep the local copy, but take a copy of the remote file and bring it here (if we don't already have it I guess!)
	echo "  IGNORES symlinks in the remote location."
	jshwarn "BUG: do not end remotedir in a / - this will cause FAIL!"
	exit 0
fi

# if [ "$1" = "" ] || [ "$1" = --help ]
# then
# more << !
# Usage: ftp_grab_backup <host> <user> <pass> <remote_folder>"
# !
# fi

FILELIST=filelist-"$REMOTEHOST-`echo "$REMOTEFOLDER" | tr / _`.`geekdate`"

jshinfo "Getting remote file list..."

if [ "$USE_SFTP" ]
then memo -t "20 minutes" ssh "$SSH_USERHOST" ls -lR "$REMOTEFOLDER" > "$FILELIST".ncftp ## "$REMOTEFOLDER"/ was needed for kx, since ~/ut is actually a symlink!
else

	echo "ls -l -R $REMOTEFOLDER" |
	memo -t "20 minutes" verbosely ncftp -u "$USERNAME" -p "$PASSWORD" "$REMOTEHOST" |
	# ssh "$USERNAME"@"$REMOTEHOST" "ls -l -R $REMOTEFOLDER" |
	cat > "$FILELIST".ncftp

fi

. importshfn memo
. importshfn rememo

jshinfo "Stripping.."
cat "$FILELIST.ncftp" > "$FILELIST.ncftp.b4stripping"
cat "$FILELIST.ncftp" |
## Some IGNORE_REGEXP s work on filenames, and these are important since convert_ftp_response_to_filestats is SO slow!
if [ "$IGNORE_REGEXP" ]
then grep -v "^-.*$IGNORE_REGEXP"
else cat
fi |
dog "$FILELIST.ncftp"

jshinfo "Converting to tree list..."
memo -t "20 minutes" convert_ftp_response_to_filestats "$REMOTEFOLDER" "$FILELIST".ncftp |
# tee "$FILELIST".fixed |
## Some IGNORE_REGEXPs work on file paths:
if [ "$IGNORE_REGEXP" ]
then grep -v "$IGNORE_REGEXP"
else cat
fi |
grep "^-" > "$FILELIST"

function download_file() {
	if [ "$USE_SFTP" ]
	then
		## TODO NASTY BUG: if i do the ssh in the foreground, the outermost while loop crashes.  The following is a nasty workaround with anti-flooding.
		# while [ "`findjob "ssh $SSH_USERHOST" | wc -l`" -gt 20 ]; do sleep 3; done
		# sleep 3 ; verbosely ssh "$SSH_USERHOST" cat "$1" > "$2" &
		scp "$SSH_USERHOST":"$1" "$2"
	else verbosely wget -nv --user="$USERNAME" --password="$PASSWORD" "ftp://$REMOTEHOST/$1" -O - > "$2"
	fi
}

function recycle() {
	if [ "$KEEP_OLD_VERSIONS" ]
	then
		# verbosely mv "$1" "$1".$GEEKDATE
		# GEEKDATE=`date -r "$1" +"%Y%m%d-%H%M"` ## we don't actually have hours and minutes
		GEEKDATE=`date -r "$1" +"%Y%m%d"`
		if [ "$TEST" ]
		then echo "Would move $1 to $1.$GEEKDATE"
		else verbosely mv "$1" "$1".$GEEKDATE
		fi
	else
		if [ "$TEST" ]
		then echo "Would delete $1"
		else del "$1"
		fi
	fi
}

jshinfo "Scanning for new/changed files..."

cat "$FILELIST" |

catwithprogress |

while read PERMS NODE OWNER GROUP REMOTE_FILE_SIZE DATE1 DATE2 DATE3 FILEPATH
do

	## Do we already have this file?

	if [ -e "$TARGET_DIR/$FILEPATH" ] || [ -f "$TARGET_DIR/$FILEPATH" ] || [ -L "$TARGET_DIR/$FILEPATH" ]
	then
		# jshinfo "Already got: $TARGET_DIR/$FILEPATH"
		## Check size is correct
		LOCAL_FILE_SIZE=`filesize "$TARGET_DIR/$FILEPATH"` ## find size of symlink contents, not link size
		if [ "$LOCAL_FILE_SIZE" = "$REMOTE_FILE_SIZE" ]
		then
			# jshinfo "Matches: $TARGET_DIR/$FILEPATH"
			continue
			# jshwarn "$TARGET_DIR/$FILEPATH size $LOCAL_FILE_SIZE != $REMOTE_FILE_SIZE"
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
			if [ "`filesize "$FILE"`" = "$REMOTE_FILE_SIZE" ]
			then
					jshinfo "We can use: $FILE for $FILEPATH"
					if [ "$TEST" ]
					then echo "Would link $FILE to $TARGET_DIR/$FILEPATH" >&2
					else
						mkdir -p "`dirname "$TARGET_DIR/$FILEPATH"`"
						( [ -f "$TARGET_DIR/$FILEPATH" ] || [ -L "$TARGET_DIR/$FILEPATH" ] ) && recycle "$TARGET_DIR/$FILEPATH"
						verbosely ln -s "$FILE" "$TARGET_DIR/$FILEPATH"
					fi
					echo "OK: $FILE" ## for the grep . later
					break ## kill the find; since we don't need it anymore
			else
				# jshinfo "We cannot use: $FILE for $FILEPATH"
				:
			fi
		done | grep . >/dev/null && continue
	fi

	if [ ! "$?" = 0 ] && [ "$TEST" ] || ( [ ! -f "$TARGET_DIR/$FILEPATH" ] && [ ! -L "$TARGET_DIR/$FILEPATH" ] ) ## added extra checks 'cos i kept breaking the echo/grep
	then
		if [ "$TEST" ]
		then echo "Would download $FILEPATH to $TARGET_DIR/$FILEPATH"
		else
			## TODO: optionally recycle (check-in) old file if it exists (we could check that it's not just a partial d/l)
			jshwarn "No suitable candidate for $FILEPATH"
			mkdir -p "`dirname "$TARGET_DIR/$FILEPATH"`" &&
			cd "$TARGET_DIR" &&
			download_file "$FILEPATH" "$TARGET_DIR/$FILEPATH"
			touch -d "$DATE1 $DATE2 $DATE3" "$TARGET_DIR/$FILEPATH"
		fi
	fi

done

jshinfo "Checking for local files which have been deleted on the source..."
cd "$TARGET_DIR"
find . -type f -or -type l |
sed 's+^./++' |
grep -v "\.[0-9]*$" | ## ignore historical backups of old copies made by KEEP_OLD_VERSIONS.
grep "/" | ## TODO: must be in a subdir - avoids files in current dir when actually target is ./<remote_filename> or ./<full_remote_path>, but is that always how we should work?
grep -v "[0-9]*_then_deleted$" | ## ignore ones generated by self!
if [ "$IGNORE_REGEXP" ]
then grep -i -v "$IGNORE_REGEXP"
else cat
fi |
catwithprogress |
while read LOCALFILE
do
	LFRE="`toregexp "$LOCALFILE"`"
	if grep -i "[ /]$LFRE$" "$FILELIST" >/dev/null ## with the sftpmethod, it's actually " ut_server/$LFRE$"
	then :
	else
		# jshwarn "Failed to find re \"$LFRE\" in $FILELIST"
		GEEKDATE=`date -r "$LOCALFILE" +"%Y%m%d"`
		if [ "$TEST" ]
		then echo "Would move $LOCALFILE to $LOCALFILE.`geekdate`_then_deleted"
		else verbosely mv "$LOCALFILE" "$LOCALFILE".`geekdate`_then_deleted
		fi
	fi
done

if [ "$KEEP_OLD_VERSIONS" ]
then jshinfo "Old versions were saved as <file>.<modification_date>"
fi

