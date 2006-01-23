DISK_IMAGE_FILE="$1"
PARTITION_NUMBER="$2"
MOUNT_POINT="$3"

CACHETIME="5 minutes"

get_info_from_fdisk () {
	# memo -t "$CACHETIME" get_info_from_fdisk_unmemoed
	get_info_from_fdisk_unmemoed
}

get_info_from_fdisk_unmemoed () {
	(
		echo "u"
		echo "p"
		echo "q"
	) |
	/sbin/fdisk "$DISK_IMAGE_FILE"
}

list_offset_size_partition () {
	SECTORSIZE=`get_info_from_fdisk | grep "^Units" | afterlast "= " | beforelast " bytes"`
	get_info_from_fdisk | fromline -x "^ *Device" | toline -x "^$" |
	# while read PART BOOT START END BLOCKS ID SYSTEM
	## BOOT is not always there
	## so remove it if it is:
	sed 's+\*++' |
	while read PART START END BLOCKS ID SYSTEM
	do
		SIZE=$(((END-START)*SECTORSIZE))
		# PART=`echo "$PART" | afterlast /`
		OFFSET=$((START*SECTORSIZE))
		echo "$OFFSET $SIZE $PART"
	done
}

if [ ! "$PARTITION_NUMBER" ] || [ ! "$MOUNT_POINT" ] || [ "$1" = --help ]
then
	echo "mount_diskimg_partition <disk_image_file> <partition_number> <mount_point>"
	if [ "$DISK_IMAGE_FILE" ]
	then
		echo
		list_offset_size_partition
	fi
	exit 1
fi

DISK_IMAGE_FILE_REGEXP=`toregexp "$DISK_IMAGE_FILE"`
list_offset_size_partition |
grep " $DISK_IMAGE_FILE_REGEXP$PARTITION_NUMBER\$" |
head -n 1 | ## shouldn't be needed really!
(
	read OFFSET_IN_DISKIMG PARTITION_SIZE PARTITION_NAME
	# jshinfo "OFFSET_IN_DISKIMG=$OFFSET_IN_DISKIMG"
	# jshinfo "PARTITION_SIZE=$PARTITION_SIZE"
	# jshinfo "PARTITION_NAME=$PARTITION_NAME"
	if [ "$PARTITION_NAME" = "$DISK_IMAGE_FILE$PARTITION_NUMBER" ]
	then
		REALOFFSET=$((OFFSET_IN_DISKIMG+OFFSET))
		verbosely mount -o loop,offset="$REALOFFSET" "$DISK_IMAGE_FILE" "$MOUNT_POINT"
	else
		error "Looking for $FILEPATH but got $PARTITION_NAME"
	fi
)
