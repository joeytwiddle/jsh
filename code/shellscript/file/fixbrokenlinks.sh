if test "$1" = ""
then
	echo "fixbrokenlinks <in_dir> <scope_dir>..."
	echo "  don't worry it doesn't overwrite anything - just suggests something to |sh"
	exit 1
fi

## TODO: make a verion that can take an index file (eg a cksum list) as scope
##       eg. to find files lost onto some indexed backup medium

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
		## hmm difficult if it means a string diff no
		## or split the original and highlight any matches, yeah that'd do
		CANDIDATES=`grep "/$SEEK\$" "$FILELIST"`
		CANDIDATESCNT=`printf "%s" "$CANDIDATES" | countlines`
		XTRA="# "
		if test "$CANDIDATESCNT" = "1"
		then
			XTRA=""
		fi
			cursered
			echo "## $CANDIDATESCNT possibilities for \"$SYMLINK\" -> \"$ORIGTARGET\":"
			cursenorm
			printf "$CANDIDATES" | sed 's|\(.*\)|'"$XTRA"'ln -sf "\1" "'"$SYMLINK"'"|'
		echo
	fi
done

jdeltmp $FILELIST
