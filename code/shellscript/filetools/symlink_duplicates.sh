if [ "$2" = "" ] || [ "$1" = --help ]
then

	echo
	echo "[ DO= | DO=1 ] symlink_duplicates <dir> <absolute_archive_dirs>..."
	echo
	echo "  For each file in <dir>, will try to find a copy of that file in one of the <archive_dirs>."
	echo "  If one is found, the file in <dir> will be removed and replaced by a symlink to the copy from <archive_dirs>."
	echo "  Assumes any duplicate file copy will have the same name, otherwise misses them."
	echo
	exit 0

fi

DIR="$1"
shift

for absDir
do
	if ! startswith "$absDir" /
	then
		echo "Need absolute path to archive dir: $absDir"
		exit 3
	fi
done

maybe_do() {
	if [ -z "$DO" ]
	then echo "Would do: $*"
	else verbosely "$@"
	fi
}

find "$DIR"/ -type f |

# catwithprogress |

while read FILE
do

	FILENAME=`filename "$FILE"`

	find "$@" -type f -name "$FILENAME" |

	while read POSSIBLE_TARGET_FILE
	do

		if cmp "$FILE" "$POSSIBLE_TARGET_FILE" >/dev/null && [ ! "`realpath "$FILE"`" = "`realpath "$POSSIBLE_TARGET_FILE"`" ]
		then
			maybe_do rm -f "$FILE"
			# maybe_do del "$FILE"
			maybe_do ln -s "$POSSIBLE_TARGET_FILE" "$FILE"
			# break
			## What on earth is this for?  It didn't appear to prevent multiple files from being linked!
			while read DUMMY; do : ; done
		fi

	done

done

