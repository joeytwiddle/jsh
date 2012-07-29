#!/bin/bash

# OMG!  Why have we coerced this into working for ssh, at the expense of ftp
# support, when we already have sftp_sync?!  This may have been a port of it!
# This should be the ftp-only version, for when scp and ssh are unavailable.

# Preserve permissions
SCP_OPTIONS="$SCP_OPTIONS -p"

## BUGS: On one server some text files appeared as 2 or 4 bytes longer remotely than the file we received locally, so these were always repeat-fetched. :|

function convert_ftp_response_to_filestats() {
	## TODO: This does not do what it should if "$1" starts with "/"
	(
		echo "$1:"
		cat "$2" | fromline "^[d-]"
	) | ls-Rtofilelist -l
}

if [[ "$1" =~ ^sftp:// ]]
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

# KEEP_OLD_VERSIONS=true
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

## Now using ls -L remotely, so that symlinks appear as normal files.
## Should work ok.  My scp was copying a remote symlink home as a file.
if [ "$USE_SFTP" ]
then memo -t "20 minutes" ssh $SSH_OPTIONS "$SSH_USERHOST" ls -lRL "$REMOTEFOLDER" > "$FILELIST".ncftp ## "$REMOTEFOLDER"/ was needed for kx, since ~/ut is actually a symlink!
else

	echo "ls -l -R $REMOTEFOLDER" |
	memo -t "20 minutes" verbosely ncftp -u "$USERNAME" -p "$PASSWORD" "$REMOTEHOST" |
	# memo -t "20 minutes" verbosely ssh $SSH_OPTIONS "$USERNAME"@"$REMOTEHOST" "ls -l -R $REMOTEFOLDER" |
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
## This grep strips symlinks and any other special filetypes, leaving only ordinary files:
grep "^-" > "$FILELIST"

function download_file() {
	if [ "$USE_SFTP" ]
	then
		## TODO NASTY BUG: if i do the ssh in the foreground, the outermost while loop crashes.  The following is a nasty workaround with anti-flooding.
		# while [ "`findjob "ssh $SSH_OPTIONS $SSH_USERHOST" | wc -l`" -gt 20 ]; do sleep 3; done
		# sleep 3 ; verbosely ssh $SSH_OPTIONS "$SSH_USERHOST" cat "$1" > "$2" &
		verbosely scp $SCP_OPTIONS "$SSH_USERHOST":"$1" "$2".tmp
	else verbosely wget -nv --user="$USERNAME" --password="$PASSWORD" "ftp://$REMOTEHOST/$1" -O - > "$2".tmp
	fi
	if [ "$?" = 0 ]
	then mv -f "$2".tmp "$2"
	fi
}

function recycle() {
	## We never keep broken links - we always delete them
	if [ "$KEEP_OLD_VERSIONS" ] && ! ( [ -L "$1" ] && [ ! -f "$1" ] )
	then
		# verbosely mv "$1" "$1".$GEEKDATE
		# GEEKDATE=`date -r "$1" +"%Y%m%d-%H%M"` ## we don't actually have hours and minutes
		GEEKDATE=`date -r "$1" +"%Y%m%d"`
		[ "$GEEKDATE" = "" ] && GEEKDATE="________"
		GEEKDATE="$GEEKDATE"_then_deleted
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

printf "" > files_to_bring.list

cat "$FILELIST" |

# catwithprogress |

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
		memo -t "5 minutes" find $SEARCH_FOLDERS_FOR_MATCH -type f | grep -i "/$FILENAMEREGEXP$" |
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
			[ "$DATE1" = "@" ] && DATE1=""
			## TODO: optionally recycle (check-in) old file if it exists (we could check that it's not just a partial d/l)

			# jshinfo "No suitable candidate for $FILEPATH"
			# mkdir -p "`dirname "$TARGET_DIR/$FILEPATH"`" &&
			# cd "$TARGET_DIR" &&
			# download_file "$FILEPATH" "$TARGET_DIR/$FILEPATH" &&
			# touch -d "$DATE1 $DATE2 $DATE3" "$TARGET_DIR/$FILEPATH"

			jshinfo "Queuing for download: $FILEPATH"
			echo "$FILEPATH" >> files_to_bring.list

		fi
	fi

done

if [ "`cat files_to_bring.list`" = "" ]
then
	jshinfo "No new files to bring!"
else
	if [ "$USE_SFTP" ]
	then

		jshinfo "Copying files from server"

		# ## BUG: This method does not fully work if there are same-named files to
		# ## be retrieved from/for different folders.
		# ## However, subsequent passes should catch up with those missed, and this
		# ## is a nice simple algorithm that requires only one ssh connection.
		# ## BUG TODO: This was supposed to grab them all with only one login, but
		# ## it turns out scp is so dumb it logs in once for each file.
		# mkdir -p sftp_got || exit 99
		# 
		# ## Copy all files into sftp_got/ folder.
		# (
			# cat files_to_bring.list |
			# sed "s+^+$SSH_USERHOST:+" |
			# # (s and )s and ' 's need to be escaped for withalldo or scp dunno which:
			# sed 's+[() ]+\\\0+g'
			# # Finally, target:
			# echo "./sftp_got/"
		# ) |
		# withalldo scp $SCP_OPTIONS
		# 
		# ## Move downloaded files into the appropriate folders.
		# cat files_to_bring.list |
		# ## If there are multiple files with the same name, the last one downloaded will have overwritten the earlier ones.
		# ## So we should put it into the dir of the last one, so we reverse the list!
		# reverse |
		# while read FILEPATH
		# do
			# FILENAME="`basename "$FILEPATH"`"
			# FILEDIR="`dirname "$FILEPATH"`"
			# mkdir -p "$FILEDIR"
			# verbosely mv -f ./sftp_got/"$FILENAME" ./"$FILEPATH"
		# done

		## A better solution might look like:
		cat ./files_to_bring.list |
		# Escape chars which will otherwise fail: '(' ')' and ' '
		sed 's+\([() ]\)+\\\1+g' |
		withalldo ssh "$SSH_USERHOST" tar cz |
		tar xzv

	else
		jshwarn "TODO: Support for multiple file retrieval with FTP."
		jshwarn "FILES in files_to_bring.list NOT DOWNLOADED!"
	fi
fi

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
		## jshwarn "Failed to find re \"$LFRE\" in $FILELIST"
		# GEEKDATE=`date -r "$LOCALFILE" +"%Y%m%d"`
		# if [ "$TEST" ]
		# then echo "Would recycle $LOCALFILE to $LOCALFILE.`geekdate`_then_deleted"
		# else verbosely mv "$LOCALFILE" "$LOCALFILE".`geekdate`_then_deleted
		# fi
		recycle "$LOCALFILE"
	fi
done



if [ "$KEEP_OLD_VERSIONS" ]
then jshinfo "Old versions were saved as <file>.<modification_date>"
fi

