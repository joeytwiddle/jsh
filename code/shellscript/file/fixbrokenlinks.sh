if test "$1" = ""
then
	echo "fixbrokenlinks <in_dir> <scope_dir>..."
	exit 1
fi

INDIR="$1"
shift

FILELIST=`jgettmp fixbrokenlinks_filelist`

find "$@" > $FILELIST

find "$INDIR" -type l |

while read SYMLINK
do
	if test ! -e "$SYMLINK"
	then
		ORIGTARGET=`justlinks "$SYMLINK"`
		# echo "Missing: \"$SYMLINK\" -> \"$ORIGTARGET\""
		SEEK=`echo "$SYMLINK" | afterlast /`
		## TODO: construct a sed string to colour in those known path-parts of the original link
		CANDIDATES=`grep "/$SEEK\$" "$FILELIST"`
		CANDIDATESCNT=`printf "%s" "$CANDIDATES" | countlines`
		if test "$CANDIDATESCNT" = "1"
		then
			echo "ln -sf \""$CANDIDATES"\" \""$SYMLINK"\""
		else
			echo "## $CANDIDATESCNT possibilities for \"$SYMLINK\" -> \"$ORIGTARGET\":"
			printf "$CANDIDATES" | sed "s+^+#  +"
		fi
		echo
	fi
done

jdeltmp $FILELIST
