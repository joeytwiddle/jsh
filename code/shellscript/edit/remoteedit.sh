## remoteedit <filename_in_local_directory> <user>@<remote_host>

## Shouldn't this be the other way around?
## Well yes there will soon be an editremote script.
## But this version is useful when:
##   - You do not have a direct connection from local -> remote but you can from remote -> local
## Also, I thought maybe it might be used as the remote part in an ssh connection initiated locally, which can slip jsh meta-data through the stream.  Yeah right!

FIFO=`jgettmp fifo`
rm -f "$FIFO"
mkfifo "$FIFO"

FILENAME="$1"
WHERE="$2"

send () {
	echo "[local] sending \"$*\"" >&2
	echo "$*"
}

local_prog () {
	send "$FILENAME"
	SIZE=`filesize "$FILENAME"`
	send "$SIZE"
	cat "$FILENAME"
	
	while read INPUT
	do
		if [ "$INPUT" = file_saved ]
		then
			read SIZE
			echo "[local] receiving file size $SIZE" >&2
			dd bs=1 count=$SIZE of="$FILENAME" 2> /dev/null &&
			echo "[local] got $FILENAME" >&2 ||
			echo "[local] error downloading $FILENAME" >&2
		else
			echo "[local] erroneous input: \"$INPUT\""
		fi
	done

}

REMOTE_PROG='

	read FILE
	read SIZE
	FILE="/tmp/$FILE"
	mkdir `dirname "$FILE"`
	dd bs=1 count=$SIZE of=$FILE
	echo "You should now edit $FILE on $HOST" >&2

	WATCH=$FILE.watch

	touch -r "$FILE" "$WATCH"
	while true
	do
		sleep 5
		NEWSIZE=` find "$FILE" -newer "$WATCH" -printf "%s\n" `
		if [ "$NEWSIZE" ]
		then
			touch -r "$FILE" "$WATCH" ## touch now for sensitivity to quickly repeated saves
			echo "[remote] file changed" >&2
			echo "file_saved"
			echo "$NEWSIZE"
			cat "$FILE"
		fi
	done

'



cat $FIFO |

local_prog |

ssh $WHERE "$REMOTE_PROG" |

cat > $FIFO



jdeltmp $FIFO
