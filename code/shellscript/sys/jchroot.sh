TARGET="$1"

[ "$TARGET" ] || exit 1


### Initialise

chroot "$TARGET" mount -t proc /proc proc

mv "$TARGET"/dev/null "$TARGET"/dev/null.b4
touch "$TARGET"/dev/null
chmod ugo+rw "$TARGET"/dev/null

mv "$TARGET"/dev/zero "$TARGET"/dev/zero.b4
dd if=/dev/zero bs=1024 count=100 of="$TARGET"/dev/zero
chmod ugo+r "$TARGET"/dev/zero

## Bind all the same mounts
TARGET=`echo "$TARGET" | tr -s / | sed 's+/$++'`
for MNTPNT in /mnt/*
do
	REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
	if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && ! cat /etc/mtab | grep "$REGEXP"
	then mount --bind "$MNTPNT" "$TARGET"/"$MNTPNT"
	fi
done



### Chroot

chroot "$@"



### Cleanup (should only do this if we are the last chroot to leave this TARGET)

chroot "$TARGET" umount -lf /proc

mv -f $TARGET/dev/null.b4 $TARGET/dev/null
mv -f $TARGET/dev/zero.b4 $TARGET/dev/zero

## Unbind all those mounts
for MNTPNT in /mnt/*
do
	REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
	if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && cat /etc/mtab | grep "$REGEXP"
	then umount "$TARGET"/"$MNTPNT"
	fi
done

