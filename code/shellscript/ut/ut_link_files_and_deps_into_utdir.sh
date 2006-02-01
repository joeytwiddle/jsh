SUPPORTING_FILE_DIRS=/stuff/software/games/unreal/server/

# DO_CHILDREN=true

IGNORE_PKGS="\(MyLevel\|Color\|BotPack\|GenFX\|GenFluid\|LavaFX\)" ## anything in ut_win_pure
## See ut_finddeps for a better version

[ "$DO_LINK" ] || DO_LINK="verbosely ln -s"
# DO_LINK="verbosely cp"

dirfor () {
	FILETYPE=`echo "$1" | afterlast "\." | tolowercase`
	case "$FILETYPE" in
		unr) TARGET="Maps" ;;
		uax) TARGET="Sounds" ;;
		umx) TARGET="Music" ;;
		unr) TARGET="Maps" ;;
		utx) TARGET="Textures" ;;
		u|int|ini|so) TARGET="System" ;;
		*) jshwarn "No target for $FILETYPE ($1)"
	esac
	echo "$TARGET"
}

link_ut_file () {
	UTFILE="$1"
	FILENAME=`basename "$UTFILE"`
	TARGET_SUBDIR="`dirfor "$FILENAME"`"
	if [ ! "$TARGET_SUBDIR" ]
	then
		error "Cannot link $FILENAME"
	else
		TARGET_DIR="$TARGET_UT_HOMEDIR"/"$TARGET_SUBDIR"
		if [ -e "$TARGET_DIR/$FILENAME" ]
		then jshinfo "Already exists: $TARGET_DIR/$FILENAME"
		else $DO_LINK "$UTFILE" "$TARGET_DIR/"
		fi
	fi
}

TARGET_UT_HOMEDIR="$1"

while read UTFILE
do

	export IKNOWIDONTHAVEATTY=true

	link_ut_file "$UTFILE"

	OWN_PACKAGE="`echo "$UTFILE" | afterlast / | beforelast \.`"

	verbosely memo -t "1 day" ut_finddeps "$UTFILE" |
	grep -v -i "^$IGNORE_PKGS\$" |
	grep -v "^$OWN_PACKAGE\$" |
	while read DEP
	do
		jshinfo "Considering $DEP"
		# if [ "$DO_CHILDREN" ] ## current implementation is dangerous (recurses on one file if it appears to depend on itself)
		# then
			# verbosely memo eval " find $SUPPORTING_FILE_DIRS -iname '$DEP.u*' | ut_link_files_and_deps_into_utdir '$TARGET_UT_HOMEDIR' "
		# else
			verbosely memo find $SUPPORTING_FILE_DIRS -iname "$DEP.u*" |
			# foreachdo link_ut_file
			while read F; do link_ut_file "$F"; done
		# fi
	done

done

