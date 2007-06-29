for TARGET
do

	if [ -f "$TARGET" ]
	then

		MNTPNT=/mnt/lazy/"`basename "$TARGET" | tr " " "_" | sed 's+[^- _.0-9A-Za-z]*++g'`"
		verbosely mkdir -p "$MNTPNT" || continue

		if endswith "$TARGET" iso
		then

			verbosely mount -o loop,ro -t iso9660 "$TARGET" "$MNTPNT"

		else

			verbosely mount -o loop "$TARGET" "$MNTPNT" ||
			verbosely mount_diskimg_partition "$TARGET" 1 "$MNTPNT"

		fi

	fi

done
