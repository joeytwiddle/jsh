## lazymount makes it easier to mount .iso files or disk-image files (e.g. created by dd).
## Uses mount_diskimg_partition for the latter.
## TODO: Make non-jsh version

if [ "$USER" = root ]
then SUDO=
else SUDO=sudo
fi

for TARGET
do

	if [ -f "$TARGET" ]
	then

		### We are going to try to mount this target.

		## Where are we going to mount it?  What are we going to call it?  Remove nasty chars.
		MNTPNT=/mnt/lazy/"`basename "$TARGET" | tr " " "_" | sed 's+[^- _.0-9A-Za-z]*++g'`"
		verbosely $SUDO mkdir -p "$MNTPNT" || continue

		if endswith "$TARGET" iso
		then

			verbosely $SUDO mount -o loop,ro -t iso9660 "$TARGET" "$MNTPNT"

		else

			verbosely $SUDO mount -o loop "$TARGET" "$MNTPNT" ||
			verbosely $SUDO $JPATH/tools/mount_diskimg_partition "$TARGET" 1 "$MNTPNT"

		fi

		[ "$?" = 0 ] && jshinfo "Mounted $TARGET at $MNTPNT" || jshwarn "Failed to mount $TARGET"

	fi

done
