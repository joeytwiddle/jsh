LETTERS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LETTER=C

# TARGET_FOLDER="$HOME/Desktop"
TARGET_FOLDER="$HOME/Desktop/My Computer"

mkdir -p "$TARGET_FOLDER" || exit 123

cat /etc/fstab |
grep "^/dev/[hs]d" |

## Generate a letter for each disk partition (Windows style)
while read LINE
do
	echo "$LETTER $LINE"
	LETTER=`echo "$LETTER" | tr "_$LETTERS" "$LETTERS"`
done |

reverse |

while read LETTER DEVICE MNTPOINT FSTYPE OPTIONS DUMP PASS
do

	if [ -d "$MNTPOINT" ]
	then

		MNTNAME=`echo "$MNTPOINT" | sed 's+.*/++'`
		FILE="$TARGET_FOLDER"/"Drive $LETTER $MNTNAME ($FSTYPE)"

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

## TODO: make cdrom part of the /etc/fstab parse too!

cat > "$TARGET_FOLDER"/"CD-Rom Drive" << !
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

cat > "$TARGET_FOLDER"/"Floppy Disc" << !
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

## I think this was an attempt at ordering the icons on the Desktop:
# [ -f "$HOME/Desktop/Home" ] && touch "$HOME/Desktop/Home"
# [ -f "$HOME/Desktop/Install to harddisk" ] && touch "$HOME/Desktop/Install to harddisk"

