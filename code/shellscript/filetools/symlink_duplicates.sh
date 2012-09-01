if [ "$*" = "" ] || [ "$1" = --help ]
then

	echo "symlink_duplicates <dir> <absolute_archive_dirs>..."
	echo
	echo "  For each file in <dir>, will try to find a copy of that file in one of the <archive_dirs>."
	echo "  If one is found, the file in <dir> will be removed and replaced by a symlink to the copy from <archive_dirs>."
	exit 0

fi

DIR="$1"
shift

find "$DIR"/ -type f |

catwithprogress |

while read FILE
do

	FILENAME=`filename "$FILE"`

	find "$@" -type f -name "$FILENAME" |

	while read POSSIBLE_TARGET_FILE
	do

		if cmp "$FILE" "$POSSIBLE_TARGET_FILE" >/dev/null && [ ! "`realpath "$FILE"`" = "`realpath "$POSSIBLE_TARGET_FILE"`" ]
		then
			verbosely rm "$FILE"
			verbosely ln -s "$POSSIBLE_TARGET_FILE" "$FILE"
			# break
			while read DUMMY; do : ; done
		fi

	done

done

