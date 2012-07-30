# Break on first error
set -e
# BUG TODO: Fails to do the ln if first arg has trailing slash, e.g. "a_folder/"

TARGET="`lastarg "$@"`"

if [ -d "$TARGET" ]
then

	for ARG in "$@"
	do

		if [ ! "$ARG"  = "$TARGET" ]
		then
			verbosely mv "$ARG" "$TARGET"/ &&
			verbosely ln -s "$TARGET"/"`basename "$ARG"`" "$ARG"
		fi

	done

else

	. errorexit "Last arg should be a directory."

fi


# if [ -d "$2" ]
# then
	# FILENAME="`filename "$1"`"
	# mv "$1" "$2" &&
	# ln -s "$2"/"$FILENAME" "$1"
# else
	# mv "$1" "$2" &&
	# ln -s "$2" "$1"
# fi

