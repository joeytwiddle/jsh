LETTERS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LETTER=C

mkdir -p "$HOME/Desktop" || exit 123

## Because we go in reverse; we need to get the last letter!
cat /etc/fstab | grep "^/dev/hd" |
while read LINE
do
	echo "$LETTER $LINE"
	LETTER=`echo "$LETTER" | tr " $LETTERS" "$LETTERS"`
done |

reverse |

while read LETTER DEVICE MNTPOINT FSTYPE OPTIONS DUMP PASS
do

	if [ -d "$MNTPOINT" ]
	then

		MNTNAME=`echo "$MNTPOINT" | sed 's+.*/++'`
		FILE="$HOME/Desktop/Drive $LETTER $MNTNAME ($FSTYPE)"

		(
			echo "[Desktop Entry]"
			echo "Dev=$DEVICE"
			echo "Icon=hdd_mount"
			echo "MountPoint=$MNTPOINT"
			echo "Type=FSDevice"
			echo "UmountIcon=hdd_unmount"
		) > "$FILE"

	fi

done

cat > $HOME/Desktop/"CD-Rom Drive" << !
[Desktop Action Eject]
Exec=kdeeject %v
Name=Eject

[Desktop Entry]
Actions=Eject
Dev=/dev/cdrom
Encoding=UTF-8
Icon=cdrom_mount
MountPoint=/cdrom
ReadOnly=true
Type=FSDevice
UnmountIcon=cdrom_unmount
X-KDE-Priority=TopLevel
!

cat > $HOME/Desktop/"Floppy Disc" << !
[Desktop Action Format]
Exec=kfloppy %v
Name=Format

[Desktop Entry]
Actions=Format
Dev=/dev/fd0
Encoding=UTF-8
Icon=3floppy_mount
MountPoint=/floppy
ReadOnly=false
Type=FSDevice
UnmountIcon=3floppy_unmount
X-KDE-Priority=TopLevel
!

[ -f "$HOME/Desktop/Home ] && touch $HOME/Desktop/Home
[ -f "$HOME/Desktop/"Install to harddisk" ] && touch $HOME/Desktop/"Install to harddisk"

