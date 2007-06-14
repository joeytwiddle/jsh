if [ "$1" = --help ]
then

	echo "df [ <path>s ]"
	exit 1

fi

if [ ! "$*" ]
then

	flatdf -h |
	# grep -v "/mnt/.*/mnt/" | ## BUG: Skips my bound mounts, but also skips sometimes wanted loopback fs-es.  E.G.: /mnt/data/utquery.ext2                       135M   13K  125M   1% /mnt/utquery   OR   /mnt/gentoo/qemu_disk_images/win98.491meg.diskimg                       486M  291M  196M  60% /mnt/tmp
	grep -v "/mnt/[^ ]*/mnt/" ## a bit better but still not really proper (should really be done at stage when flatdf is getting list of mounts, so bound mounts can be detected properly)

else

	for WHERE
	do
		MOUNTPNT="`wheremounted \"$WHERE\"`"
		REALPATH=`realpath "$WHERE"`
		REST=`echo "$REALPATH" | afterfirst "$MOUNTPNT"`
		flatdf -h |
		grep -v "/mnt/.*/mnt/" | ## Skips my bound mounts
		grep "$MOUNTPNT$" |
		sed "s|[ 	]$MOUNTPNT| $MOUNTPNT`cursegreen`$REST`cursenorm`|g" |
		if [ -d "$MOUNTPNT/RECLAIM" ]
		then
			RECLAIMABLE=`dush "$MOUNTPNT/RECLAIM" 2>/dev/null | takecols 1`
			sed 's|\([	 ]*[[:digit:]]*%\)| + '"$RECLAIMABLE"'\1|'
		else
			cat
		fi
	done

fi |
columnise
