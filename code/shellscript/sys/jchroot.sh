#!/bin/sh
## See also: joey/project/gentoo/chroot_into_gentoo.sh which has isActiveMountPoint().

## TODO: Auto-configure network.  For me requires doing ifconfig up on relevant interfaces, and dhclient on the main one.

## TODO: jchroot should do something like:
##       echo "From $SOURCE at `date`" > $TARGET/tmp/chrooted_from.last

## TODO: it is safer to do a bind mount than to do a mount from within the chroot.  Therefore we should always mount a partition if it is listed in the chroot's fstab, and any partitions which are not listed should have a mountpoint (e.g. /mnt/hdb2) created in the chroot, and then bind mounted, to avoid the need to mount them in the chroot.
## TODO: optionally bind-mount /proc and/or /dev
## TODO: I think the currect automounting works if the inner system has some mountpoints with the same name as the outer system.
##       This should be made optional, and maybe it should create the mountpoints if they don't exist.

# if [ "$1" = -fixdev ]
# then FIXDEV=true; shift
# fi

# if [ "$1" = -fixmounts ]
# then FIXMOUNTS=true; shift
# fi

TARGET="$1"

[ "$TARGET" ] || exit 1


# export HOST="$HOST"_chroot_"$1"
# export HOSTNAME="$HOSTNAME"_chroot_"$1"
# export SHORTHOST="$SHORTHOST"_chroot_"$1"
# export SHOWHOST="$SHOWHOST"_chroot_"$1"
# export SHORTHOST="chroot@$SHORTHOST:$1"
export PROMPTHOST="chroot:`echo "$1" | afterlast /`"
## CONSIDER: maybe better to export CHROOT_IS=... and let anything below pick it up.


export HIGHLIGHTSTDERR=true

jbindmount () {
	if mount | grep "^$1 on $2 type none (.*,bind)$" >/dev/null
	then echo "$1 is already bind-mounted on $2"
	else verbosely mount --bind "$1" "$2"
	fi
}

fix_proc () {
	verbosely chroot "$TARGET" mount -t proc /proc proc ||
	jbindmount /proc "$TARGET"/proc
	## TODO: We should test if $TARGET/proc is a folder, otherwise bind mount will fail.
}

undo_fix_proc () {
	mount | grep "^/proc on $TARGET/proc .*bind" >/dev/null ||
	verbosely chroot "$TARGET" umount -lf /proc
	verbosely umount "$TARGET"/proc
}

## TODO: why is this declared twice?!

fix_dev () {
	mount | grep "^/dev on $TARGET/dev .*bind" >/dev/null ||
	jbindmount /dev "$TARGET"/dev
	jbindmount /dev/pts "$TARGET"/dev/pts
}

undo_fix_dev () {
	verbosely umount "$TARGET"/dev/pts
	verbosely umount "$TARGET"/dev
}

fix_parent () {
	[ -d "$TARGET"/CHROOT_PARENT ] || verbosely mkdir -p "$TARGET"/CHROOT_PARENT
	jbindmount / "$TARGET"/CHROOT_PARENT
}

undo_fix_parent () {
	verbosely umount "$TARGET"/CHROOT_PARENT
	rmdir "$TARGET"/CHROOT_PARENT
}

# This doesn't appear to do much good gentoo -> debian.  But maybe it's needed the other way?
## Ah no, I think the deal was that this was needed until I implemented bind mounting of /dev then it was no longer needed.
## TODO: it's also pretty nasty if this script doesn't exit cleanly, and they don't get cleaned up!
##       but how could we fix that?  some SIGHUP interrupt?  or add a cleanup init script to the target?!
fix_dev_null_zero_hack () {
	if [ ! -e "$TARGET"/dev/null.b4 ]
	then
		verbosely mv "$TARGET"/dev/null "$TARGET"/dev/null.b4
		verbosely touch "$TARGET"/dev/null
		verbosely chmod ugo+rw "$TARGET"/dev/null
	fi
	if [ ! -e "$TARGET"/dev/zero.b4 ]
	then
		verbosely mv "$TARGET"/dev/zero "$TARGET"/dev/zero.b4
		verbosely dd if=/dev/zero bs=1024 count=100 of="$TARGET"/dev/zero
		verbosely chmod ugo+r "$TARGET"/dev/zero
	fi
}

undo_fix_dev_null_zero_hack () {
	# # cp -a /dev/null "$TARGET"/dev/null
	# # cp -a /dev/zero "$TARGET"/dev/zero
	# mv -f $TARGET/dev/null.b4 $TARGET/dev/null
	# mv -f $TARGET/dev/zero.b4 $TARGET/dev/zero
	if [ -e "$TARGET"/dev/null.b4 ]
	then verbosely mv -f "$TARGET"/dev/null.b4 "$TARGET"/dev/null
	fi
	if [ -e "$TARGET"/dev/zero.b4 ]
	then verbosely mv -f "$TARGET"/dev/zero.b4 "$TARGET"/dev/zero
	fi
}

fix_mounts_original_hack () {
	## Bind all the same mounts
	TARGET=`echo "$TARGET" | tr -s / | sed 's+/$++'`
	for MNTPNT in /dev /home /mnt/*
	do
		REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
		if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && ! cat /etc/mtab | grep "$REGEXP"
		then
			jshinfo "Mounting (regexp was \"$REGEXP\") ..."
			jbindmount "$MNTPNT" "$TARGET"/"$MNTPNT"
		fi
	done
}

undo_fix_dev_null_zero_hack () {
	## Unbind all those mounts
	for MNTPNT in /dev /home /mnt/*
	do
		REGEXP=`echo "^$MNTPNT $TARGET/$MNTPNT .*\<bind\>" | tr -s /`
		if [ ! "$MNTPNT" = "$TARGET" ] && [ -d "$MNTPNT" ] && [ -d "$TARGET"/"$MNTPNT" ] && cat /etc/mtab | grep "$REGEXP"
		then verbosely umount "$TARGET"/"$MNTPNT"
		fi
	done
}

fix_mounts_simple_bind () {
	jbindmount /mnt "$TARGET"/mnt
}

fix_mounts_many_binds () {
	for MNTPNT in /mnt/*
	do
		mount | takecols 3 | grep "^$MNTPNT$" &&
		jbindmount "$MNTPNT" "$TARGET"/"$MNTPNT"
	done
}

undo_fix_mounts_simple_bind () {
	## Unfortunately, I think this methods leaves the subdirs under the target chroot empty!
	verbosely umount "$TARGET"/mnt
}

undo_fix_mounts_many_binds () {
	for MNTPNT in /mnt/*
	do
		mount | takecols 3 | grep "^$MNTPNT$" &&
		verbosely umount "$TARGET"/"$MNTPNT"
	done
}

fix_mounts_check_fstab () {
	## Checks fstab of target against local mounts
	cat "$TARGET"/etc/fstab |
	grep -v "^#" | trimempty |
	# pipeboth | ## a lot!
	while read DEV MNTPNT FSTYPE OPTIONS BOOT CHECK
	do
		[ "$MNTPNT" = / ] && continue ## avoid this one!  presumably done before we called jchroot :P
		[ -d "$TARGET"/"$MNTPNT" ] || continue
		mount | grep "^$DEV " |
		while read LDEV on LMNTPNT type LTYPE LOPTIONS
		do
			if [ "$UNDO" ]
			then verbosely umount "$TARGET"/"$MNTPNT"
			# then verbosely mount -o umount --bind "$LMNTPNT" "$TARGET"/"$MNTPNT"
			else
				jshinfo "Device $LDEV on $LMNTPNT should appear at $TARGET/$MNTPNT"
				jbindmount "$LMNTPNT" "$TARGET"/"$MNTPNT"
			fi
			break
		done
	done
}

undo_fix_mounts_check_fstab () {
	UNDO=true fix_mounts_check_fstab
}


# [ "$FIXDEV" ] && fix_dev_null_zero_hack
# # [ "$FIXDEV" ] && fix_dev
# [ "$FIXMOUNTS" ] && fix_mounts_original_hack


fix_proc ## This was disabled, but we want it, provided it doesn't keep causing mess.
# fix_dev ; fix_mounts_check_fstab
## Was fix_proc causing the "not enough t/ptys" error?
fix_dev ; fix_mounts_check_fstab
fix_parent

check_exec () {
	if mount | grep " on $TARGET[ 	].*\<noexec\>"
	then
		jshinfo "Remounting FS with exec"
		verbosely mount -o remount,exec "$TARGET"
	fi
}

check_exec

### Chroot

## TODO: if "$*" = "" then run su - ?

## TODO: also setup headers/prestrings for the screen and shell prompts; review and combine them all :)
# xttitle "chroot: $*"
XTTITLE_PRESTRING_BEFORE="$XTTITLE_PRESTRING"
export XTTITLE_PRESTRING="$XTTITLE_PRESTRING""jchroot[$*]: "

xttitle "chroot-$TARGET $XTTITLE_PRESTRING_BEFORE" ## hardly needed; if xttitle is working, then jsh will probably apply it soon in the shell prompt

jshinfo "Entering chroot $TARGET"
# chroot "$@"
chroot "$@" env XTTITLE_PRESTRING="$XTTITLE_PRESTRING" bash
## Causes: "no job control in this shell"
# verbosely chroot "$@" env XTTITLE_PRESTRING="$XTTITLE_PRESTRING" bash
jshinfo "Leaving chroot $TARGET"

### Cleanup (should only do this if we are the last chroot to leave this TARGET)

undo_fix_proc ; undo_fix_dev ; undo_fix_mounts_check_fstab
undo_fix_parent

# [ "$FIXDEV" ] && undo_fix_dev_null_zero_hack
# [ "$FIXMOUNTS" ] && undo_fix_mounts_original_hack

