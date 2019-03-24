#!/bin/sh
if [ ! "$1" ] || [ "$1" = --help ]
then
	echo "fixbrokenlinks <in_dir> <scope_dirs>..."
	echo "fixbrokenlinks <in_dir> -list <scope_list_file>"
	echo "  For each broken link found in <in_dir>, tries to find a matching filename in one of the <scope_dirs> or the <scope_list>."
	echo "  Don't worry it doesn't overwrite anything - just suggests something to |sh"
	exit 1
fi

## TODO: I think the search is just be filename
##       But sometimes the *path* of the broken link contains useful information to find where the target went.

## Progress: make a verion that can take an index file (eg a cksum list) as scope
##           eg. to find files lost onto some indexed backup medium
## See /stuff/cdlistings/makebiglist .sh and use -list
## Now TODO: instead of ln, pin files so they get copied off the needed cd

INDIR="$1"
shift

FILELIST=`jgettmp fixbrokenlinks_filelist`

if [ "$1" = "-list" ]
then cat "$2"
else verbosely find "$@" -type f
fi > $FILELIST

verbosely find "$INDIR" -type l |

while read SYMLINK
do
	if [ ! -e "$SYMLINK" ]
	then
		ORIGTARGET=`justlinks "$SYMLINK"`
		# echo "Missing: \"$SYMLINK\" -> \"$ORIGTARGET\""
		SEEK=`echo "$SYMLINK" | afterlast / | toregexp`
		## TODO: construct a sed string to colour in those known path-parts of the original link
		## hmm difficult if it means a string diff no
		## or split the original and highlight any matches, yeah that'd do
		## nah soddit why bother?!
		# CANDIDATES=`grep "/$SEEK\$" "$FILELIST"`
		CANDIDATES=`grep "/$SEEK\$" "$FILELIST" | filesonly` ## Added filesonly in case the provided list contains non-files
		CANDIDATESCNT=`printf "%s" "$CANDIDATES" | countlines`
		XTRA="# "
		if [ "$CANDIDATESCNT" = "1" ]
		then
			XTRA=""
		fi
		echo "## `curseblue`$CANDIDATESCNT possibilities for \"$SYMLINK\" -> \"$ORIGTARGET\":`cursenorm`"
		#printf "%s" "$CANDIDATES" | sed 's|\(.*\)|'"$XTRA"'ln -sf "\1" "'"$SYMLINK"'"|'
		# Do not show N possibilities; just show the first
		printf "%s" "$CANDIDATES" | head -n 1 | sed 's|\(.*\)|ln -sf "\1" "'"$SYMLINK"'"|'
		echo
	fi
done

jdeltmp $FILELIST
