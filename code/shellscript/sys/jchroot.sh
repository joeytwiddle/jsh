if [ "$1" = -fixdev ]
then FIXDEV=true; shift
fi

TARGET="$1"

[ "$TARGET" ] || exit 1


### Initialise

chroot "$TARGET" mount -t proc /proc proc

## This doesn't appear to do much good gentoo -> debian.  But maybe it's needed the other way?
## TODO: it's also pretty nasty if this script doesn't exit cleanly, and they don't get cleaned up!
##       but how could we fix that?  some SIGHUP interrupt?  or add a cleanup init script to the target?!
if [ "$FIXDEV" ]
then
	if [ ! -e "$TARGET"/dev/null.b4 ]
	then
		mv "$TARGET"/dev/null "$TARGET"/dev/null.b4
		touch "$TARGET"/dev/null
		chmod ugo+rw "$TARGET"/dev/null
	fi
	if [ ! -e "$TARGET"/dev/zero.b4 ]
	then
		mv "$TARGET"/dev/zero "$TARGET"/dev/zero.b4
		dd if=/dev/zero bs=1024 count=100 of="$TARGET"/dev/zero
		chmod ugo+r "$TARGET"/dev/zero
	fi
fi

## Bind all the same mounts
TARGET=`echo "$TARGET" | tr -s / | sed 's+/$++'`
for MNTPNT in /mnt/*
do
	REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
	if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && ! cat /etc/mtab | grep "$REGEXP"
	then
		jshinfo "Mounting (regexp was \"$REGEXP\") ..."
		mount --bind "$MNTPNT" "$TARGET"/"$MNTPNT"
	fi
done



### Chroot

## TODO: if "$*" = "" then run su - ?

chroot "$@"



### Cleanup (should only do this if we are the last chroot to leave this TARGET)

chroot "$TARGET" umount -lf /proc

if [ "$FIXDEV" ]
then
	if [ -e "$TARGET"/dev/null.b4 ]
	then mv -f "$TARGET"/dev/null.b4 "$TARGET"/dev/null
	fi
	if [ -e "$TARGET"/dev/zero.b4 ]
	then mv -f "$TARGET"/dev/zero.b4 "$TARGET"/dev/zero
	fi
fi

# # cp -a /dev/null "$TARGET"/dev/null
# # cp -a /dev/zero "$TARGET"/dev/zero
# mv -f $TARGET/dev/null.b4 $TARGET/dev/null
# mv -f $TARGET/dev/zero.b4 $TARGET/dev/zero

## Unbind all those mounts
for MNTPNT in /mnt/*
do
	REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
	if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && cat /etc/mtab | grep "$REGEXP"
	then umount "$TARGET"/"$MNTPNT"
	fi
done
