case "$1" in
	"-h"|"--help")
		echo "bringlinkhere [-nolink] [<files/dirs>]"
		echo "  will bring all symbolic links found here,"
		echo "  and unless -nolink provided, will link those moved files back."
		exit 0
		;;
	"-nolink")
		NOLINK=true
		shift
		;;
esac

find "$@" -type l | while read LNK; do
	DEST=`justlinks "$LNK"`
	ABSLNK=`absolutepath "$LNK"`
	# echo "$LNK -> $DEST"
	if test ! -f "$DEST" && test ! -d "$DEST"; then
		echo "# NOT MOVING: target is not file or dir: $LNK"
	else
		echo "rm \"$LNK\""
		echo "mv \"$DEST\" \"$LNK\""
		echo "ln -s \"$ABSLNK\" \"$DEST\""
	fi
done
