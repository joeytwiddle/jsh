FIFO=`jgettmp fifo`
rm -f "$FIFO"
mkfifo "$FIFO"

FILENAME="$1"
WHERE="$2"

send () {
	echo "local: sending \"$*\"" >&2
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
			echo "local: receiving file size $SIZE" >&2
			dd bs=1 count=$SIZE of="$FILENAME"
			echo "local: done" >&2
		else
			echo "local: erroneous input: \"$INPUT\""
		fi
	done

}

REMOTE_PROG='

	read FILE
	read SIZE
	FILE="/tmp/$FILE"
	mkdir `dirname "$FILE"`
	dd bs=1 count=$SIZE of=$FILE
	echo "You should now edit $FILE on $HOST|$HOSTNAME" >&2

	WATCH=$FILE.watch

	while true
	do
		touch -r "$FILE" "$WATCH"
		while true
		do
			sleep 5
			if find "$FILE" -newer "$WATCH" -printf "file_saved\n%s\n"
			then
				cat "$FILE"
				break
			fi
		done
	done

'

cat $FIFO |

local_prog |

ssh $WHERE "$REMOTE_PROG" |

cat > "$FIFO"
