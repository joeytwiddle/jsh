MNTTARGET=`realpath "$1"`
MNTPNT=`realpath "$2"`

FILELIST=/tmp/filelist.txt
BEFOREMARKER=/tmp/beforemarker.time
SENDING_STATE=/tmp/lastsend.time

cd "$MNTTARGET"
find . -type f > $FILELIST

cd "$MNTPNT"
cat $FILELIST |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DIR"
	mkfifo "$FILE"
done

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
		jshinfo "[send] PASS"
		cat $FILELIST |
		while read FILE
		do
			jshinfo "[send] Trying: $FILE"
			touch $SENDING_STATE
			touch $BEFOREMARKER

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

			BS=1
			while true
			do
				dd if="$MNTTARGET"/"$FILE" of="$MNTPNT"/"$FILE" bs=$BS count=0 2> /tmp/dd.out &
				DDPID="$!"
				sleep 1
				kill -USR1 "$DDPID" >> /tmp/dd.out
				CONTENT=`cat /tmp/dd.out`
				if [ ! "$CONTENT" ]
				then
					jshwarn "dd breaking out because no output!"
					kill "$DDPID"
					break
				fi
				if grep "^0+0 " /tmp/dd.out >/dev/null
				then
					jshinfo "dd exiting gracefully"
					kill "$DDPID"
					break
				else
					jshinfo "waiting for $BS bytes"
					wait
				fi
				sleep 1
				BS=1024
			done
			# verbosely kill "$SENDPID"
			sleep 10
		done
	done
}

send_needed_daemon
