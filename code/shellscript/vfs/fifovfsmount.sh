TARGET_ACCOUNT=joey@neuralyte.org
# MNTTARGET=`realpath "$1"`
MNTTARGET="$1"
MNTPNT=`realpath "$2"`

FILELIST=/tmp/filelist.txt
BEFOREMARKER=/tmp/beforemarker.time
SENDING_STATE=/tmp/lastsend.time

ssh "$TARGET_ACCOUNT" "cd '$MNTTARGET' && find . -type f" > $FILELIST

cd "$MNTPNT"
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

send_needed_daemon () {
	cd "$MNTPNT"
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
				# cat "$MNTTARGET"/"$FILE" |
				# notify_progress $SENDING_STATE |
				# cat > "$MNTPNT"/"$FILE"
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
				# dd if="$MNTTARGET"/"$FILE" of="$MNTPNT"/"$FILE" bs=$BS count=0 > /tmp/dd.out
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
				# dd if="$MNTTARGET"/"$FILE" of="$MNTPNT"/"$FILE" bs=$BS count=1 2> /tmp/dd.out &
				# ssh $TARGET_ACCOUNT dd if="$MNTTARGET"/"$FILE" bs=999999 count=999999 2>/dev/null |
				ssh $TARGET_ACCOUNT "dd if='$MNTTARGET/$FILE' bs=999999 count=999999 2>/dev/null" |
				while true
				do
					dd bs=1 count=1 2> /tmp/dd_inner.out
					printf "." >&2
					grep "^0" /tmp/dd_inner.out >/dev/null && break
				done |
				# (
					# dd bs=1 count=1 2>/dev/null
					# echo "++++++ First inner dd done" >&2
					# dd bs=99999999 count=999999 2>/dev/null
				# )|
				dd of="$MNTPNT"/"$FILE" bs=$BS count=$BS 2> /tmp/dd.out &
				DDPID="$!"
				sleep 1
				# kill -USR1 "$DDPID" # >> /tmp/dd.out
				kill -USR1 "$DDPID" > /tmp/killsig.out 2> /tmp/killsig.err
				# sleep 1
				CONTENT=`cat /tmp/dd.out`
				if [ ! "$CONTENT" ]
				then
					jshwarn "[send] try later: dd appears to be blocking"
					kill "$DDPID"
					# break
				# fi
				elif grep "^0+ " /tmp/dd.out >/dev/null
				then
					jshinfo "nothing transfered, aborting"
					cat /tmp/dd.out >&2
					kill "$DDPID"
					# break
					# ####
					# cat /tmp/dd.out >&2
					# jshinfo "dd will continue..."
					# dd
					# if dd if="$MNTTARGET/$FILE" of="$MNTPNT/$FILE"
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
					cat /tmp/dd.out >&2
					# jshinfo "waiting for $BS bytes"
					jshinfo "Waiting for dd to finish"
					wait
					jshinfo "dd finished"
				fi
				# sleep 1
				BS=1024
			# done # |
			# dd of="$MNTPNT"/"$FILE" 2>/tmp/dd-outer.out
			# verbosely kill "$SENDPID"
			# sleep 10
		done # || break
		jshinfo "[send] PASS (pause)"
		sleep 5
	done
}

send_needed_daemon
