if test "$1" = ""
then
	echo "fixbrokenlinks <in_dir> <scope_dirs>..."
	echo "fixbrokenlinks <in_dir> -list <scope_list_file>"
	echo "  For each broken link found in <in_dir>, tries to find a matching filename in one of the <scope_dirs> or the <scope_list>."
	echo "  Don't worry it doesn't overwrite anything - just suggests something to |sh"
	exit 1
fi

## Progress: make a verion that can take an index file (eg a cksum list) as scope
##           eg. to find files lost onto some indexed backup medium
## See /stuff/cdlistings/makebiglist .sh and use -list
## Now TODO: instead of ln, pin files so they get copied off the needed cd

INDIR="$1"
shift

FILELIST=`jgettmp fixbrokenlinks_filelist`

if test "$1" = "-list"
then
	cp "$2" "$FILELIST"
else
	find "$@" > $FILELIST
fi

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
		## nah soddit why bother?!
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
