#!/bin/sh
## For really lazy people:
## when pointed at a file, it mounts the file in the default place
## when pointed at a samba share, it mounts it in the default place

DEFAULT_FILE_MOUNT_DIR=/mnt/
DEFAULT_SAMBA_MOUNT_DIR=~/smb/

if [ "$1" = -u ]
then
	UNMOUNT=true
	shift
fi

WHAT="$1"
INNOCENT=`echo "$WHAT" | tr "/" "_"`

if [ -f "$WHAT" ]
then

	mkdir -p "$DEFAULT_FILE_MOUNT_DIR/$INNOCENT"

	if [ "$UNMOUNT" ]
	then
		umount "$DEFAULT_FILE_MOUNT_DIR/$INNOCENT"
		rmdir "$DEFAULT_FILE_MOUNT_DIR/$INNOCENT"
	else mount -o loop "$WHAT" "$DEFAULT_FILE_MOUNT_DIR/$INNOCENT"
	fi

else

	mkdir -p "$DEFAULT_SAMBA_MOUNT_DIR/$INNOCENT"

	if [ "$UNMOUNT" ]
	then
		smbumount "$DEFAULT_SAMBA_MOUNT_DIR/$INNOCENT" &&
		rmdir "$DEFAULT_SAMBA_MOUNT_DIR/$INNOCENT"
	else smbmount "$WHAT" "$DEFAULT_SAMBA_MOUNT_DIR/$INNOCENT"
	fi

fi
