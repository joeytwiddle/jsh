## Developers:
## It should be easy to create your own vfs methods.  All that needs implementing is:
##   a function to return the list of files in the VFS, as seen by the user,
##   a function to read a file from within the VFS, to stdout,
##   a function to write a file into the VFS, from stdin,
##   a syntax line in the documentation below,
##   and some argument parsing for the new method.

## For debugging: jwatchchanges 'findjob ssh | higrep cat'

## I hoped we might be able to use lsof to infer which fifo the user might be
## trying to read from or to.  But unfortunately, entries in my lsof do not appear
## until the fifo has be joined at both ends!

## This script is dedicated to Ellis, born today!



###### Documentation

if [ "$1" = "" ] || [ "$1" = --help ]
then
more << !

fifovfsmount [ -rw ] -ssh <user>@<host>:<dir> <mountpoint>
fifovfsmount [ -rw ] -gzip <dir_of_gzips> <mountpoint>
fifovfsmount [ -rw ] -zip <zipfile> <mountpoint>

  will create a fifo vfs under <mountpoint> of the remote/zipped dir/files,
  and start a transfer server, with the following limitations:

    -ssh needs ssh authentication to be setup to access the remote account:
     [ -f ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa
     cat ~/.ssh/id_rsa.pub | ssh <user>@<host> "cat >> ~/.ssh/authorized_keys"

    Average delay is proportional to the number of files, so do not choose
    a <dir> with too leafy a tree (lots of files).

    The vfs will be read-only unless the -rw option is specified.

    The fifos will not display any file permissions, dates or size.

    Seeking into files will probably not work.

    It's not a proper filesystem; you can't add or delete files or directores.
    (Actually you can get away with mkfifo in some modes, to make a new file.)

    You have to hold down Ctrl+C to close the server, then cleanup the mount-
    point's fifos yourself: rm -rf <mountpoint>/*

How does it work?

  It creates a set of fifos under <mountpoint> corresponding to the tree under
  <path> or the zipfiles.

  It then watches these files for read access by attempting a dd into each one
  in turn (sourcing the stream, delayed, from the remote machine).  If, after
  one decisecond, dd is not happily writing to the fifo, then it stops the
  ssh sourcing stream, and hence dd, and tries the next file instead.

  For write access, it just tries to cat from each file in turn.  If the cat
  has produced no bytes in 0.1 seconds, it is killed, otherwise its data is
  transferred into to the remote file.

BUGS:

  Some machines need to sleep longer than 0.3 and 0.1, although it's desirable
	to keep them as low as possible.  TODO: test for optimal values before start.

  Obviously trying each file in turn is terrible.  You can run staggered
  instances of the server!  I tried to get lsof to tell us which fifo might
  be being accessed at any time, but it refused (until the fifo was opened!).
  We could instead try to get "hints" from ps commands, and maybe lsof on
  directories (to check).

  Writing does not require the dd hack, so actually most bugs are with reading.

  The server's dd does not exit until the file has finished being read.
  So the client can only read one file at a time.

  The server gets confused if the fifo isn't closed straight after being read,
  and blocks the next time the file is polled.  A tap on Ctrl+C will unblock it.
  Maybe fixable if the server ensures the fifo has been closed before resuming.
  Added this hack, but still problems if they drop the stream part-way through.
  (Also the hack might interfere with valid multiple-readers of a file.)
  Need to try to find a more generic way to kill blocked dd's...
  Well we could keep asking for total transfer, and kill the dd if it hasn't
  sent anything for 1 minute.  But for that we would want to background sends =)
  OK it now checks using the USR1 signal hack again.  Server now more resilient
  (and messy!).
  Actually this is an experimental version which just about manages to fix the
  streaming reading problems, but has broken zipfs.

  Useful in case of problems:

    mykill -x "sh /home/joey/linux/j/tools/fifovfsmount"

    killall dd

Some programs for which it works:

  cat, vim (r+w!), mutt (ro), cp, grep, diff, mplayer, mpg123, make, lynx, sh

And some for which it does not work: (eg. they try to seek)

  konqueror, mozilla, convert, gqview, gimp, mpg321, xmms, gcc, links

!
## Not so sure any more:
#  Aside from this script's obvious inefficiencies, the fifos on my Linux
#  system seem to work slowly themselves (when there are only 2 cats running).
exit 1
fi



###### Initialisation and argument parsing

FILELIST=/tmp/fifovfs_filelist.$$.txt
GO_AHEAD_MARKER=/tmp/fifovfs_goahead.$$.marker
TMPFILE=/tmp/fifovfs_tempfile.$$.tmp
DO_READING=true
DO_WRITING=

if [ "$1" = -rw ]
then DO_WRITING=true; shift
fi
if [ "$1" = -ssh ]
then
	shift
	TARGET="$1"
	shift
	TARGET_ACCOUNT=`echo "$TARGET" | sed 's+:.*++'`
	TARGET_DIR=`echo "$TARGET" | sed 's+.*:++'`
	COMMAND_TO_GET_FILELIST=ssh_command_to_get_filelist
	## Hack to make kill work:
	# COMMAND_TO_READ=ssh_command_to_read
	COMMAND_TO_READ='ssh $SSH_OPTS $TARGET_ACCOUNT cat \"$TARGET_DIR/$FILE\" &'
	COMMAND_TO_WRITE=ssh_command_to_write
elif [ "$1" = -gzip ]
then
	shift
	TARGET_DIR=`realpath "$1"`
	shift
	COMMAND_TO_GET_FILELIST=gzip_command_to_get_filelist
	COMMAND_TO_READ=gzip_command_to_read
	COMMAND_TO_WRITE=gzip_command_to_write
elif [ "$1" = -zip ]
then
	shift
	ZIPFILE=`realpath "$1"`
	shift
	COMMAND_TO_GET_FILELIST=zip_command_to_get_filelist
	COMMAND_TO_READ=zip_command_to_read
	COMMAND_TO_WRITE=zip_command_to_write
  [ "$DO_WRITING" ] && echo "Sorry WRITING is NOT yet IMPLEMENTED for the ZIP method."
else
  echo "-ssh -gzip and -zip are the only valid protocols at the moment."
  exit 1
fi
MOUNTPOINT=`realpath "$1"`

jshinfo () {
  printf "\033[00;33m%s\033[00;00m\n" "$*" >&2
}

jshhappy () {
  printf "\033[00;32m%s\033[00;00m\n" "$*" >&2
}



###### ssh functions

## SSH_OPTS can be set by user, eg. if they want to specify a non-default port
ssh_print_warning () {
cat >&2 << !

If you are prompted for your password, then ssh authentication is not setup.
Press Ctrl+C and type the following before retrying:
[ -f ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub | ssh <user>@<host> "cat >> ~/.ssh/authorized_keys"

!
}
ssh_command_to_get_filelist () {
  ssh_print_warning
	# ssh "$TARGET_ACCOUNT" "cd '$TARGET_DIR' && find . -type f" > $FILELIST
	ssh $SSH_OPTS "$TARGET_ACCOUNT" "cd '$TARGET_DIR' && find . -follow -not -type d"
}
## Hacked out to make kill work:
## This is now executed inline =)
# ssh_command_to_read () {
  # ssh $SSH_OPTS $TARGET_ACCOUNT "cat '$TARGET_DIR/$FILE'"
# }
ssh_command_to_write () {
  ssh $SSH_OPTS $TARGET_ACCOUNT "cat > '$TARGET_DIR/$FILE'"
}



###### gzip functions

# gzip_command_to_get_filelist () {
	# cd "$TARGET_DIR" &&
	# find . -name "*.gz" | sed 's+\.gz$++'
# }
# gzip_command_to_read () {
	# gunzip -c "$TARGET_DIR/$FILE.gz"
# }
# gzip_command_to_write () {
	# gzip -c > "$TARGET_DIR/$FILE.gz"
# }



###### better gzip functions

## These don't yet strip the ".tar" off (if it was added)
gzip_command_to_get_filelist () {
	cd "$TARGET_DIR" &&
	find . -name "*.gz" | sed 's+\.gz$++'
	find . -name "*.bz2" | sed 's+\.bz2$++'
	find . -name "*.tgz" | sed 's+\.tgz$+.tar+'
}
gzip_command_to_read () {
	if [ -f "$TARGET_DIR/$FILE.gz" ]
	then gunzip -c "$TARGET_DIR/$FILE.gz"
	elif [ -f "$TARGET_DIR/$FILE.bz2" ]
	then bunzip -c "$TARGET_DIR/$FILE.bz2"
	elif echo "$FILE" | grep "\.tar$"
	then
		TGZFILE=`echo "$FILE" | sed 's+\.tar$+.tgz+'`
		gunzip -c "$TARGET_DIR/$TGZFILE"
	else
		echo "Ain't nothing there." >&2
		return 1
	fi
}
gzip_command_to_write () {
	if echo "$FILE" | grep "\.tar$"
	then
		TGZFILE=`echo "$FILE" | sed 's+\.tar$+.tgz'`
		gzip -c > "$TARGET_DIR/$TGZFILE"
	elif [ -f "$TARGET_DIR/$FILE.bz2" ]
	then bzip -c > "$TARGET_DIR/$FILE.bz2"
	else gzip -c > "$TARGET_DIR/$FILE.gz"
	fi
}



###### zip functions

zip_command_to_get_filelist () {
	unzip -v "$ZIPFILE" |
	(
		read LABEL ARCHIVENAME
		read FIELDHEADERS
		read BAR
		while read LENGTH METHOD SIZE RATIO DATE TIME CRC32 NAME
		do
			[ "$LENGTH" = "--------" ] && break
			echo "$NAME"
		done
	)
}
zip_command_to_read () {
	FILE=`echo "$FILE" | sed 's+^\./++'`
	unzip -p "$ZIPFILE" "$FILE"
}
zip_command_to_write () {
	echo "Writing not yet enabled for zip files." >&2
	echo "(I think I would have to recreate its path... which is easy but I'm lazy.  Not too lazy to write this though.)" >&2
	cat > /dev/null
	return 1
}



###### Main program

# ssh-agent ## Dunno if this makes later ssh's faster...?! nope!

$COMMAND_TO_GET_FILELIST |
if [ "$PATH_FILTER_REGEXP" ]
then grep "$PATH_FILTER_REGEXP"
else cat
fi > $FILELIST
## Eg.: to not descend directories: PATH_FILTER_REGEXP="^\./[^/]*$"

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
  [ "$1" ] && CHAR="$1" || CHAR=.
  CNT=1
	while true
	do
		dd bs=1 count=$CNT 2> /tmp/dd_inner.out
		grep "^0" /tmp/dd_inner.out >/dev/null && break
		printf "$CHAR" >&2
		# CNT=`expr $CNT '*' 2`
    CNT=1024
	done
}

do_reading () {

  FILE="$1"

  jshinfo "[READ] Polling fifo: $FILE"

  BS=99999999
  rm -f $GO_AHEAD_MARKER
  (
    sleep 0.3
		## Hacked to get kill to work:
    # [ -f $GO_AHEAD_MARKER ] &&
		# $COMMAND_TO_READ
    if [ -f $GO_AHEAD_MARKER ]
		then
      eval "$COMMAND_TO_READ"'
      COMMAND_PID="$!"
      echo "$COMMAND_PID" > $GO_AHEAD_MARKER
      '
    fi
  ) |
  notify_progress "<" |
  dd of="$MOUNTPOINT"/"$FILE" bs=$BS count=$BS 2> /tmp/dd.out &
  DDPID="$!"

  sleep 0.1 ## This seems neccessary for the below:

  ## Well how odd!  It appears that if the fifo is not being read, then this signal kills the dd, but if it is being read, the dd survives, and echos to stderr as it should =)
  kill -USR1 "$DDPID" # > /tmp/killsig.out 2> /tmp/killsig.err ## I guess I commented these because we expect this kill to work, and output nothing?

  CONTENT=`cat /tmp/dd.out`
  if [ ! "$CONTENT" ]
  then
    jshinfo "[READ] dd has (probably) died => file not being read"
  else
    touch $GO_AHEAD_MARKER
    jshhappy "[READ] PUSHING Waiting for dd to finish..."
		## I believe this wait was no good if the local user gives up reading the stream.
		## In that case we want to kill the process and release this vfsdaemon to scan other files.
		## Hence the rest of the paragraph!
    # wait
    ## Hack to ensure dd hasn't started blocking:
    while true
    do
      sleep 2
      # printf "" > /tmp/dd.out
      kill -USR1 "$DDPID" || break
      # cat /tmp/dd.out
    done
    jshinfo "[READ] dd has now died, telling command to stop..."
    # killall ssh cat zip unzip gzip gunzip
    COMMAND_PID=`cat $GO_AHEAD_MARKER`
    [ "$COMMAND_PID" ] && kill "$COMMAND_PID"
    rm -f $GO_AHEAD_MARKER
    jshinfo "[READ] PUSHED OK dd finished."

    # ## Hack to ensure remote reader has finally closed the reading of the file:
    # ## (Otherwise streamers such as media players cause the file to be sent
    # ##  again because it hasn't yet finished playing the file it has.)
    # ## This didn't deal with blocked dd's however, so above hack fixes both.
    # ## Although this might be tidy to avoid unneccessary block, it might not be so good in other circumstances.
    # while true
    # do
      # jshinfo "[READ] Waiting for reader to release stream..."
      # dd if=/dev/zero of="$MOUNTPOINT"/"$FILE" bs=$BS count=$BS 2> /tmp/dd.out &
      # DDPID="$!"
      # sleep 0.1
      # kill -USR1 "$DDPID"
      # CONTENT=`cat /tmp/dd.out`
      # if [ ! "$CONTENT" ]
      # then break
      # fi
      # kill "$DDPID"
      # sleep 1
    # done
    # jshinfo "[READ] OK they have let go."
  fi

  # wait ## We don't have to wait for the ssh clause to finish, but if we don't it might get confused (picking up a goahead/sending_state tag meant for a later file) but who cares anyway?!
  ## Oh it appears it is needed.  Without it the first send never finishes!

}

do_writing () {

  FILE="$1"

  jshinfo "[WRITE] Polling fifo: $FILE"

  rm -f $TMPFILE
  cat "$MOUNTPOINT/$FILE" > $TMPFILE &
  ## Below oesn't kill the cat in this form:
  # cat "$MOUNTPOINT/$FILE" |
  # notify_progress "<" |
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
    # cat $TMPFILE | notify_progress ">" | ssh $TARGET_ACCOUNT "cat > '$TARGET_DIR/$FILE'" &&
    cat $TMPFILE | notify_progress ">" | $COMMAND_TO_WRITE &&
    ## Yeah this notify shows a local buffer; ideally it would be beyond the slowness (eg. running at the other end of the ssh)
    jshhappy "[WRITE] File sent OK" ||
    jshinfo '[WRITE] ERROR sending file!'
    sleep 5
  else
    jshinfo '[WRITE] No data so killing cat'
    kill "$CATPID" ## presumably blocked
  fi

  # wait ## Why not?!

}

polling_transfer_daemon () {

	cd "$MOUNTPOINT"

	while true
	do

    ## I wonder if we shouldn't use the fifos rather than the old list.  Beyond scope.
		# cat $FILELIST |
    find . -type p |
		while read FILE
		# for FILE in `cat $FILELIST` ## No spaces in filenames allowed with this method!
		do

      if [ "$DO_READING" ]
      then

        echo
        do_reading "$FILE"

      fi

      if [ "$DO_WRITING" ]
      then

        echo
        do_writing "$FILE"

      fi

      wait

      true

		done # || break # this is good for user Ctrl+C'ing, oh but I think it is causing exit after successful read, dunno why!, maybe cos there is nothing to wait for! Fixed with true above.

		echo
		jshinfo "[PAUSE] Pausing after a full pass over the filelist"
		echo
		sleep 2 || break

	done

}

polling_transfer_daemon
