#!/bin/sh

# This should not be called cvsdiff, because it ain't like cvs diff:
# it only finds what's missing, not what's been changed.

# echo '# Reasons for failing update:'
# echo '# cvs update 2>/dev/null | grep -v "^\? "'
# echo '# Files which are not the same as the repository versions.'
# echo '# or cvs status 2>/dev/null | grep "^File: " | grep -v "Status: Up-to-date"'
# echo "# Rats, for some reason this doesn't work recursively."

# echo "# Try cvsdiff .* * to see which local files do not exist in repository."
# echo "# Sorry subdirs' files don't work 'cos status loses path."

# TODO: when a new file (not yet in repos) is found, if the dir is also new, the dir should be "cvs add"ed too.

CHECKALL=
while true; do
	case "$1" in
		-all)
			CHECKALL=true
			SUGGEST="update"
			;;
		-del)
			CHECKALL=true
			SUGGEST="remove"
		;;
		-h|--help)
			echo "cvsdiff [ -all [ -del ] ] [<files>]"
			echo "  Without -all you get a brief listing of the status of your CVS files."
			echo "  With -all you get a full listing:"
			echo "    It suggests you add local files which are not in the repository."
			echo "    Without -del it suggests you update repository files you do not have."
			echo "    With -del it suggests removal of repository files you do not have."
			exit 1
		;;
		*)
			break
		;;
	esac
	shift
done

REPOSLIST=`jgettmp in-repos`
LOCALLIST=`jgettmp local`

PRE=`cat CVS/Root | afterlast ":"`"/"`cat CVS/Repository`"/"

echo
printf "# "
cursecyan
printf "Status of local files compared to repository:"
cursenorm
printf "\n"

cvs -z 5 -q status "$@" | egrep "(^File:|Repository revision:)" |
	# sed "s+File:[	 ]*\(.*\)[	 ]*Status:[	 ]*\(.*\)+\1:\2+" |
	sed "s+.*Status:[	 ]*\(.*\)+\1+" |
	sed "s+[	 ]*Repository revision:[^/]*$PRE\(.*\),v+\1+" |
	while read X; do
		read Y;
		echo "$Y	# "`curseyellow`"$X"`cursenorm`
		echo "./$Y" >> /dev/stderr
	done 2> $REPOSLIST |
	grep -v "Up-to-date" |
	if jwhich column quietly; then
		column -t -s "	"
	else
		cat
	fi

if test $CHECKALL; then

	# jfc nolines $LOCALLIST $REPOSLIST |
		# sed "s+^./+cvs add ./+"

	if test "$1" = ""; then
		find . -type f
	else
		# originally just for X; but no good on Solaris
		for X in "$@"; do echo "./$X"; done
		# for X; do echo "./$X"; done
	fi | grep -iv "/CVS/" > $LOCALLIST

	echo
	printf "# "
	cursecyan
	printf "Local directories not in repository:"
	cursenorm
	printf "\n"

	find . -type d |
	grep -v "/CVS" |
	while read D; do
		if test ! -d "$D/CVS"; then
			echo "cvs add $D"
		fi
	done

	echo
	printf "# "
	cursecyan
	printf "Local files not in repository:"
	cursenorm
	printf "\n"

	jfcsh $LOCALLIST $REPOSLIST |
		sed "s+^./+cvs add ./+"

	echo
	printf "# "
	cursecyan
	printf "Repository files missing locally:"
	cursenorm
	printf "\n"
	jfcsh $REPOSLIST $LOCALLIST |
		sed "s+^./+cvs $SUGGEST ./+"

fi

echo

# jdeltmp $REPOSLIST $LOCALLIST

exit 0
