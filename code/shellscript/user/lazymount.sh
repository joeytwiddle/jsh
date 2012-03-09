## lazymount makes it easier to mount .iso files or disk-image files (e.g. created by dd).
## Uses mount_diskimg_partition for the latter.
## TODO: Make non-jsh version

if [ "$USER" = root ]
then SUDO=
else SUDO=sudo
fi

TARGET="$1"

	if [ -f "$TARGET" ]
	then

		# Has filetype been specified?
		fileType="$FILETYPE"
		# Guess filetype
		[ -z "$fileType" ] && fileType=$(echo "$fileType" | sed 's+.*\.++')

		### We are going to try to mount this target.

		## Where are we going to mount it?  What are we going to call it?  Remove nasty chars.
		MNTPNT=/mnt/lazy/"`basename "$TARGET" | tr " " "_" | sed 's+[^- _.0-9A-Za-z]*++g'`"
		verbosely $SUDO mkdir -p "$MNTPNT" || continue

		if [ "$fileType" = "iso" ]
		then

			verbosely $SUDO mount -o loop,ro -t iso9660 "$TARGET" "$MNTPNT"

		## img is the default/fallback
		# elif [ "$fileType" = "img" ]
		# then
		else

			### First try directly, works for isos, partitions
			verbosely $SUDO mount -o loop "$TARGET" "$MNTPNT" ||

			### Failing that, perhaps it is a drive image with many partitions.
			### Try to mount the first partition on the drive image.
			## Insufficient.  mount_diskimg_partition could not call toregexp, afterlast, ..., fromline.
			# verbosely $SUDO $JPATH/tools/mount_diskimg_partition "$TARGET" 1 "$MNTPNT"
			## The mount_diskimg_partition requires some scripts on its path.
			verbosely $SUDO $JPATH/jsh mount_diskimg_partition "$TARGET" 1 "$MNTPNT" ||

			jshwarn "Failed to mount $TARGET fileType=$fileType"

		fi

		[ "$?" = 0 ] && jshinfo "Mounted $TARGET at $MNTPNT" || jshwarn "Failed to mount $TARGET"

	else

		echo "Not a file: $TARGET" >&2

	fi


