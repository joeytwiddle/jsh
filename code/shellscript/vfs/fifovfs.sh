## Currently read-only, and requires ssh/RSA authentication to remote host, but works!

if [ "$1" = "" ] || [ "$1" = --help ]
then
cat | more << !

  fifovfsmount [ -rw ] -ssh <user>@<hostname>:<path> <mountpoint>

	  will create a fifo vfs under <mountpoint> of the remote directory.
    and start a transfer server, with the following limitations:

      You must have ssh authentication setup to easily access the remote account.

      Average delay is proportional to the number of files, so do not choose
      too large a tree under <path>.

      The vfs will be read only unless the -rw option is specified.

      The fifos will not display any file permissions, dates or size.

      Seeking into files will probably not work.

      It's not a proper filesystem; you can't add or delete files.

  How does it work?

    It creates a set of fifos under <mountpoint> corresponding to the tree under
    <path>.

    It then watches these files for read access by attempting a dd into each one
    in turn (sourcing the stream, delayed, from the remote machine).  If, after
    one decisecond, dd is not seen to be writing to the fifo, then it stops the
    dd, and (almost) the ssh sourcing, and tries the next file instead.

  BUGS:

    The server's dd does not exit until the file has finished being read.
    So the client can only read one file at a time.

    Aside from this script's obvious inefficiencies, the fifos on my Linux
    system seem to work slowly themselves (when there are only two cats running).

!
fi

FILELIST=/tmp/fifovfs_filelist.$$.txt
GO_AHEAD_MARKER=/tmp/fifovfs_goahead.$$.marker
TMPFILE=/tmp/fifovfs_tempfile.$$.tmp
DO_READING=true
DO_WRITING=

if [ "$1" = -rw ]
then DO_WRITING=true; shift
fi
TARGET="$1"
MOUNTPOINT=`realpath "$2"`
TARGET_ACCOUNT=`echo "$TARGET" | sed 's+:.*++'`
TARGET_DIR=`echo "$TARGET" | sed 's+.*:++'`

jshinfo () {
  printf "\033[00;33m%s\033[00;00m\n" "$*" >&2
}

jshhappy () {
  printf "\033[00;32m%s\033[00;00m\n" "$*" >&2
}

# ssh-agent ## Dunno if this makes later ssh's faster...?! nope!

# ssh "$TARGET_ACCOUNT" "cd '$TARGET_DIR' && find . -type f" > $FILELIST
ssh "$TARGET_ACCOUNT" "cd '$TARGET_DIR' && find . -not -type d" > $FILELIST

cd "$MOUNTPOINT"
cat $FILELIST |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DIR"
	jshinfo "Virtualising $FILE" >&2
	mkfifo "$FILE"
done

# exit

notify_progress () {
	NOTIFY_FILE="$1"
	BS=1
	while true
	do
		# dd bs=$BS count=1 2>/dev/null || break
		dd bs=$BS count=1 2>/tmp/dd.out || break
		if grep "^0+0 " /tmp/dd.out >/dev/null
		then
			jshinfo "[notify_progress] dd exiting gracefully"
			break
		fi
		BS=1024
	done
}

another_notify_progress () {
  [ "$1" ] && CHAR="$1" || CHAR=.
	# CNT=1024
  CNT=1
	while true
	do
		dd bs=1 count=$CNT 2> /tmp/dd_inner.out
		grep "^0" /tmp/dd_inner.out >/dev/null && break
		printf "$CHAR" >&2
		CNT=`expr $CNT '*' 2`
	done
}

send_needed_daemon () {
	cd "$MOUNTPOINT"
	while true
	do
    ## I wonder if we shouldn't use the fifos rather than the old list.
		cat $FILELIST |
		while read FILE
		# for FILE in `cat $FILELIST` ## No spaces in filenames allowed for the moment!
		do

      if [ "$DO_READING" ]
      then

        echo

        jshinfo "[READ] Trying: $FILE"

        BS=99999999
        rm -f $GO_AHEAD_MARKER
        (
          sleep 0.3
          [ -f $GO_AHEAD_MARKER ] &&
          ssh $TARGET_ACCOUNT "cat '$TARGET_DIR/$FILE'"
        ) |
        another_notify_progress "<" |
        dd of="$MOUNTPOINT"/"$FILE" bs=$BS count=$BS 2> /tmp/dd.out &
        DDPID="$!"

        sleep 0.1 ## This seems neccessary for the below:

        ## Well how odd!  It appears that if the fifo is not being read, then this signal kills the dd, but if it is being read, the dd survives, and echos to stderr as it should =)
        kill -USR1 "$DDPID" > /tmp/killsig.out 2> /tmp/killsig.err

        CONTENT=`cat /tmp/dd.out`
        if [ ! "$CONTENT" ]
        then
          jshinfo "[READ] dd has (probably) died => file not being read"
        else
          touch $GO_AHEAD_MARKER
          jshhappy "[READ] PUSHING Waiting for dd to finish..."
          wait
          jshinfo "[READ] PUSHED OK dd finished."
        fi

        # wait ## We don't have to wait for the ssh clause to finish, but if we don't it might get confused (picking up a goahead/sending_state tag meant for a later file) but who cares anyway?!
        ## Oh it appears it is needed.  Without it the first send never finishes!

      fi

      if [ "$DO_WRITING" ]
      then

        echo

        jshinfo "[WRITE] Trying: $FILE"

        rm -f $TMPFILE
        cat "$MOUNTPOINT/$FILE" > $TMPFILE &
        ## Below oesn't kill the cat in this form:
        # cat "$MOUNTPOINT/$FILE" |
        # another_notify_progress "<" |
        # cat > $TMPFILE &
        CATPID="$!"

        sleep 0.1
        # ls -l $TMPFILE
        SIZE=`find $TMPFILE -printf %s`
        if [ "$SIZE" ] && [ "$SIZE" -gt 0 ]
        then
          jshhappy '[WRITE] PULL waiting for all of file...'
          wait
          jshhappy '[WRITE] Sending file to remote filesystem...'
          # cat $TMPFILE | ssh $TARGET_ACCOUNT "cat > '$TARGET_DIR/$FILE'" &&
          cat $TMPFILE | another_notify_progress ">" | ssh $TARGET_ACCOUNT "cat > '$TARGET_DIR/$FILE'" &&
          jshhappy "[WRITE] File sent OK" ||
          jshinfo '[WRITE] ERROR sending file!'
          sleep 5
        else
          jshinfo '[WRITE] No data so killing cat'
          kill "$CATPID" ## presumably blocked
        fi

        # wait ## Why not?!

      fi

      wait

		done || break # this was good for user Ctrl+Cing

		echo
		jshinfo "[READ] PAUSING after a full pass over the filelist"
		echo
		sleep 5

	done
}

send_needed_daemon
