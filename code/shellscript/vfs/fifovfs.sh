## Currently read-only, and requires ssh/RSA authentication to remote host, but works!

if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

  fifovfs -ssh <user>@<hostname>:<path> <mountpoint>

	  will create a fifo vfs under <mountpoint> of the remote directory.
    with the following limitations:

      You must have ssh authentication setup to easily access the remote account.

      Average delay is proportional to the number of files, so do not choose
      too large a tree under <path>.

      The vfs will be read only (for the moment!).

      The fifos will not display any file permissions, dates or size.

      Seeking into files will probably not work.

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

!
fi

TARGET="$1"
TARGET_ACCOUNT=`echo "$TARGET" | sed 's+:.*++'`
TARGET_DIR=`echo "$TARGET" | sed 's+.*:++'`
# TARGET_ACCOUNT=joey@neuralyte.org
# TARGET_ACCOUNT=joey@panic.cs.bris.ac.uk
# TARGET_DIR=`realpath "$1"`
# TARGET_DIR="$1"
MOUNTPOINT=`realpath "$2"`

FILELIST=/tmp/filelist.txt
BEFOREMARKER=/tmp/beforemarker.time
SENDING_STATE=/tmp/lastsend.time

# ssh-agent ## Dunno if this makes later ssh's faster...?! nope!

ssh "$TARGET_ACCOUNT" "cd '$TARGET_DIR' && find . -type f" > $FILELIST

cd "$MOUNTPOINT"
cat $FILELIST |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DIR"
	echo "Virtualising $FILE" >&2
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
	CNT=1
	while true
	do
		dd bs=1 count=$CNT 2> /tmp/dd_inner.out
		printf "." >&2
		grep "^0" /tmp/dd_inner.out >/dev/null && break
		CNT=`expr $CNT '*' 2`
	done
}

send_needed_daemon () {
	cd "$MOUNTPOINT"
	while true
	do
		# cat $FILELIST |
		# while read FILE
		for FILE in `cat $FILELIST` ## No spaces in filenames allowed for the moment!
		do
			jshinfo "[send] Trying: $FILE"
			# touch $SENDING_STATE
			# touch $BEFOREMARKER

			# (
				# cat "$TARGET_DIR"/"$FILE" |
				# notify_progress $SENDING_STATE |
				# cat > "$MOUNTPOINT"/"$FILE"
				# jshinfo "Cats are over"
			# ) &
			# SENDPID="$!"
			# while newer $SENDING_STATE $BEFOREMARKER
			# while ps | grep "$SENDPID"
			# do
				# jshinfo "Sending ok!"
				# sleep 5
			# done

			## Nope it blocks:
			# BS=1
			# while true
			# do
				# dd if="$TARGET_DIR"/"$FILE" of="$MOUNTPOINT"/"$FILE" bs=$BS count=0 > /tmp/dd.out
				# if grep "^0+0 " /tmp/dd.out >/dev/null
				# then
					# jshinfo "dd exiting gracefully"
					# break
				# fi
				# sleep 1
				# BS=1024
			# done

			BS=99999999
			# while true
			# do
				# dd if="$TARGET_DIR"/"$FILE" of="$MOUNTPOINT"/"$FILE" bs=$BS count=1 2> /tmp/dd.out &
				# ssh $TARGET_ACCOUNT dd if="$TARGET_DIR"/"$FILE" bs=999999 count=999999 2>/dev/null |
				rm -f /tmp/goahead
				(
          sleep 0.3
          # jshinfo "Ooh looks like they want us to send it!"
          [ -f /tmp/goahead ] &&
          # ssh $TARGET_ACCOUNT "dd if='$TARGET_DIR/$FILE' bs=999999 count=999999 2>/dev/null"
          ssh $TARGET_ACCOUNT "cat '$TARGET_DIR/$FILE'"
          # jshinfo "ssh over"
				) |
				# another_notify_progress |
				# (
					# dd bs=1 count=1 2>/dev/null
					# echo "++++++ First inner dd done" >&2
					# dd bs=99999999 count=999999 2>/dev/null
				# )|
				dd of="$MOUNTPOINT"/"$FILE" bs=$BS count=$BS 2> /tmp/dd.out &
				DDPID="$!"
				sleep 0.1 ## This seems neccessary for the below:
        ## Well how odd!  It appears that if the fifo is not being read, then this signal kills the dd, but if it is being read, the dd survives, and echos to stderr as it should =)
				kill -USR1 "$DDPID" > /tmp/killsig.out 2> /tmp/killsig.err
				## I don't quite understand, but it works!
				# sleep 1
				CONTENT=`cat /tmp/dd.out`
				if [ ! "$CONTENT" ]
				then
					jshinfo "[send] dd has (probably) died; file not being read; continuing"
          # findjob "\<dd\>"
					# kill "$DDPID"
					# break
				# fi
				# elif grep "^0+" /tmp/dd.out >/dev/null
				# then
					# jshinfo "nothing transfered, aborting"
					# cat /tmp/dd.out >&2
					# kill "$DDPID"
					# break
					# ####
					# cat /tmp/dd.out >&2
					# jshinfo "dd will continue..."
					# dd
					# if dd if="$TARGET_DIR/$FILE" of="$MOUNTPOINT/$FILE"
					# # if [ "$?" = 0 ]
					# then
						# jshinfo "Finally dd exited gracefully."
						# break
					# else
						# jshinfo "Second dd failed; so er continuing!"
					# fi
					# # kill "$DDPID"
					# # break
				else
					touch /tmp/goahead
					# jshinfo "waiting for $BS bytes"
					jshinfo "`cursegreen`SENDING!`curseyellow` dd said it had done this:"
					cat /tmp/dd.out >&2
					jshinfo "`cursegreen`SENDING!`curseyellow` Waiting for dd to finish"
					wait
					jshinfo "dd finished"
				fi
				# sleep 1
				BS=1024
			# done # |
			# dd of="$MOUNTPOINT"/"$FILE" 2>/tmp/dd-outer.out
			# verbosely kill "$SENDPID"
			# sleep 10
      wait ## We don't have to wait for the ssh clause to finish, but if we don't it might get confused (picking up a goahead tag meant for a later file) but who cares anyway?!
      ## Oh it appears it is needed.  Without it the first send never finishes!
		done # || break
		echo
		jshinfo "[send] PASS (pausing)"
		echo
		sleep 5
	done
}

send_needed_daemon
