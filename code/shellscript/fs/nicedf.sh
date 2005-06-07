## Like flatdf but better - only works on one mountpoint at a time.
MNTPNT="$1"
SPACE=`
	df "$MNTPNT" |
	## This ensures that if the line overflowed (eg. because the device was a long)
	tail -n 1 |
	## This extracts the available space field, whether the file/device was dropped or not
	sed 's+^[^ .]*[ . ]*[^ .]*[ . ]*[^ .]*[ . ]*\([^ .]*\).*+\1+'
`
echo "$SPACE"
