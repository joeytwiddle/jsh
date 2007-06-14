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

list_partnum_offset_size () {
	N=1
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
		echo "$N $OFFSET $SIZE"
		N=$((N+1))
	done
}

if [ ! "$PARTITION_NUMBER" ] || [ ! "$MOUNT_POINT" ] || [ "$1" = --help ]
then
	echo "mount_diskimg_partition <disk_image_file> <partition_number> <mount_point>"
	if [ "$DISK_IMAGE_FILE" ] && [ ! "$DISK_IMAGE_FILE" = --help ]
	then
		echo
		list_partnum_offset_size
	fi
	exit 1
fi

DISK_IMAGE_FILE_REGEXP=`toregexp "$DISK_IMAGE_FILE"`
list_partnum_offset_size |
# grep " $DISK_IMAGE_FILE_REGEXP$PARTITION_NUMBER\$" |
grep "^$PARTITION_NUMBER " |
head -n 1 | ## shouldn't be needed really!
(
	read PARTITION_NAME OFFSET_IN_DISKIMG PARTITION_SIZE
	# jshinfo "OFFSET_IN_DISKIMG=$OFFSET_IN_DISKIMG"
	# jshinfo "PARTITION_SIZE=$PARTITION_SIZE"
	# jshinfo "PARTITION_NAME=$PARTITION_NAME"
	if [ "$PARTITION_NAME" = "$PARTITION_NUMBER" ]
	then
		REALOFFSET=$((OFFSET_IN_DISKIMG+OFFSET))
		verbosely mount -o loop,offset="$REALOFFSET" "$DISK_IMAGE_FILE" "$MOUNT_POINT"
	else
		error "Looking for $PARTITION_NUMBER but got $PARTITION_NAME"
	fi
)
