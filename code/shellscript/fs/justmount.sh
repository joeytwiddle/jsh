## For really lazy people:
## when pointed at a file, it mounts the file in the default place
## when pointed at a samba share, it mounts it in the default place

DEFAULT_FILE_MOUNT_DIR=/mnt/
DEFAULT_SAMBA_MOUNT_DIR=~/smb/

WHAT="$1"
INNOCENT=`echo "$WHAT" | tr "/" "_"`

if [ -f "$WHAT" ]
then

	mount -o loop "$WHAT" "$DEFAULT_FILE_MOUNT_DIR/$INNOCENT"

else

	smbmount "$WHAT" "$DEFAULT_SAMBA_MOUNT_DIR/$INNOCENT"

fi
