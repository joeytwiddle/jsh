#!/bin/sh
# export SEARCH_FOLDERS_FOR_MATCH="/stuff/ut/files/ /mnt/big/ut/ut_win /mnt/hdb6/ut_server/"
# export IGNORE_REGEXP="\(/Logs/\|/logs/\|\.tmp$\|/NetGamesUSA.com/\|/BT-\)"
# export KEEP_OLD_VERSIONS=true
# export TEST=true
## See also: ftp_grab_backup

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "Usage: sftp_sync <user>@<host>:<dir> <dir>"
	exit 0
fi

export REMOTE=`echo "$1" | beforefirst :`
export REMOTEDIR=`echo "$1" | afterfirst :`
export LOCALDIR="$2"

if [ "$REMOTE" = "" ] || [ "$REMOTEDIR" = "" ] || [ "$LOCALDIR" = "" ]
then "$0" --help ; exit 0
fi

[ "$DO" ] || TEST=true

# PATTERN='%s %TY%Tm%Td-%TH%TM%TS %p\n'
PATTERN='%s _ %p\n'

linklocalcopy () {
	FILENAME="$1"
	REMOTESIZE="$2"
	TARGETFILE="$3"
	FILENAMEGLOB="`echo "$FILENAME" | sed 's+[][]+\\\\\0+g'`"
	# jshinfo "FILENAMEGLOB=$FILENAMEGLOB"
	# find $SEARCH_FOLDERS_FOR_MATCH -type f -iname "$FILENAMEGLOB" |
	for SEARCHDIR in $SEARCH_FOLDERS_FOR_MATCH
	do find "$SEARCHDIR"/ -type f -iname "$FILENAMEGLOB"
	done |
	while read POSSFILE
	do
		if [ `filesize "$POSSFILE"` = "$REMOTESIZE" ]
		then verbosely ln -s "$POSSFILE" "$TARGETFILE" ; break
		fi
		# jshwarn "Cannot use: $POSSFILE"
		# false
	done
	# false
}

memo -t "20 minutes" verbosely ssh "$REMOTE" eval "cd '$REMOTEDIR' && find . -follow -type f -printf '$PATTERN'" | grep -v "$IGNORE_REGEXP" | sort -k 3 > remote.list
## No memoing here, in case we just ran and changed something!
( verbosely eval "cd '$LOCALDIR' && find . -follow -type f -printf '$PATTERN'" | grep -v "$IGNORE_REGEXP" | sort -k 3 > local.list )

jfcsh remote.list local.list |
while read REMOTESIZE _ REMOTEFILE
do
	if [ "$TEST" ]
	then jshinfo "$REMOTEFILE on the remote is unique."
	else
		if [ -f "$LOCALDIR"/"$REMOTEFILE" ]
		then
			jshwarn "Existing file $LOCALDIR/$REMOTEFILE mismatches remote $REMOTEFILE, so rotating it:  [rerun to fetch it!]"
			HISDATE=`date -r "$LOCALDIR/$REMOTEFILE" +"%Y%m%d-%H%M"`
			verbosely mv "$LOCALDIR/$REMOTEFILE" "$LOCALDIR/$REMOTEFILE.$HISDATE"
		fi
		if [ "$DO" ]
		then
			mkdir -p "`dirname "$LOCALDIR"/"$REMOTEFILE"`"
			linklocalcopy "`filename "$REMOTEFILE"`" "$REMOTESIZE" "$LOCALDIR/$REMOTEFILE"
			if [ ! -f "$LOCALDIR"/"$REMOTEFILE" ]
			then
				# jshinfo "TODO: get remote:$REMOTEDIR/$REMOTEFILE -> $LOCALDIR/$REMOTEFILE"
				# verbosely scp "$REMOTE":"$REMOTEDIR"/"$REMOTEFILE" "$LOCALDIR"/"$REMOTEFILE"
				# verbosely rsync -e ssh --progress -z -L "$REMOTE":"$REMOTEDIR"/"$REMOTEFILE" "$LOCALDIR"/"$REMOTEFILE"
				verbosely rsync -e ssh --progress -z8 -L "$REMOTE":"$REMOTEDIR"/"$REMOTEFILE" "$LOCALDIR"/"$REMOTEFILE" &
				# if [ 9 -gt `findjob rsync | wc -l` ]
				# then :
				# else findjob rsync ; wait
				# fi
				while [ 9 -lt `findjob rsync | wc -l` ]
				do findjob rsync ; verbosely sleep 20
				done
			fi
		fi
	fi
done

jfcsh local.list remote.list |
grep -v "\.[0-9-][0-9-]*$" | ## ignore local old versions e.g. ut/./ut-server/System/MapVoteLA.ini.20080731
grep -v "/DELETED\.[0-9-][0-9-]*/" | ## ignore deleted files (user must cleans these manually)
while read LOCALSIZE _ LOCALFILE
do
	# jshinfo "TODO: $LOCALFILE was deleted from remote, so: del \"$LOCALDIR/$LOCALFILE\""
	jshinfo "Not on remote:`cursenorm` rotating '$LOCALDIR/$LOCALFILE'"
	## No we don't want to change the filename:
	# verbosely mv "$LOCALDIR/$LOCALFILE" "$LOCALDIR/$LOCALFILE".DELETED.`geekdate`
	if [ "$DO" ]
	then
		## So instead:
		mkdir -p "$LOCALDIR"/DELETED.`geekdate`/`dirname "$LOCALFILE"`
		# verbosely mv "$LOCALDIR/$LOCALFILE" "$LOCALDIR"/DELETED.`geekdate`/`dirname "$LOCALFILE"`/
		verbosely mv "$LOCALDIR/$LOCALFILE" "$LOCALDIR"/DELETED.`geekdate`/`dirname "$LOCALFILE"`/
	fi
done

