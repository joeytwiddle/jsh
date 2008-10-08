## This implementation cannot deal with more files that shell args can take:
# if [ ! "$*" ]
# ## We weren't given any args; so presumably we were streamed the files via our input stream...
# ## WARNING: this infinitely recursive implementation will frag your system if input stream generates no args!:
# # then withalldo sortfilesbydate
# ## This one is safe:
# then withalldo ls -rtd
# else ls -rtd "$@"
# fi

[ "$SORTBY" ] || SORTBY=modify
[ "$SORTBY" = access ] && SORTFORM="%A@"
[ "$SORTBY" = modify ] && SORTFORM="%T@"
[ "$SORTBY" = status ] && SORTFORM="%C@"

if [ "$1" ]
then
	echolines "$@" | sortfilesbydate

else

	## (No longer) stream-only version:
	while read FILE
	do find "$FILE" -maxdepth 0 -printf "$SORTFORM %p\n"
	done |
	sort -n -k 1 |
	dropcols 1

fi
