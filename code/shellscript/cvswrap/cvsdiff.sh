#!/bin/sh

CHECKALL=
while true
do
	case "$1" in
		-all)
			CHECKALL=true
			SUGGEST="update"
		;;
		-del)
			CHECKALL=true
			SUGGEST="remove"
		;;
		-vimdiff)
			cvsvimdiff -all "$@"
			exit
		;;
		-h|--help)
			echo "cvsdiff [ -all [ -del ] ] [<files>]"
			echo "  Pretty prints the status of your checkout relative to the repository."
			echo "  Without -all you get a brief listing of the status of your CVS files."
			echo "  With -all you get a full listing:"
			echo "    It suggests you add local files which are not in the repository."
			echo "    Without -del it suggests you update repository files you do not have."
			echo "    With -del it suggests removal of repository files you do not have."
			echo "  Note: cvsdiff only works properly after a cvs update (see TODO)."
			echo "cvsdiff -vimdiff"
			echo "  Performs a cvsvimdiff on each uncommited file."
			echo "  If you write the file during its session, it will be committed."
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

## TODO: When your local checkout is not recently updated,
##       we seem to get a shorter REPOSLIST than we should.
## This is because "cvs status" exits with something like:
## cvs [status aborted]: could not find desired version 1.5 in ...

printf "" > $REPOSLIST

PARENT=.
cvs -z 5 status "$@" 2>&1 |
grep "\(^cvs \(status\|server\):\|^File:\)" |
	sed "
		s=^cvs \(status\|server\):[	 ]*Examining \(.*\)=PARENT \2=
		s=^File:[	 ]*\(no file\|\)\(.*\)[ 	]*Status:[	 ]*\(.*\)=\2 \3=
	" |
	while read FNAME STATUS
	do
		if test "$FNAME" = PARENT
		then
			# echo "A `cursemagenta`$FNAME $STATUS`cursenorm`"
			PARENT="$STATUS"
			read FNAME STATUS
		fi
		# echo "B `curseblue`$FNAME $STATUS`cursenorm`"
		FILE="$PARENT/$FNAME"
		echo "$FILE	# "`curseyellow`"$STATUS"`cursenorm`
		echo "$FILE" | sed 's+^\.\/++' >> $REPOSLIST
	done |
	grep -v "Up-to-date" |
	sed 's+^+cvs commit +' |
	if jwhich column quietly
	then column -t -s "	"
	else cat
	fi

if test $CHECKALL
then

	# jfc nolines $LOCALLIST $REPOSLIST |
		# sed "s+^./+cvs add ./+"

	if test "$1" = ""
	then
		find . -type f
	else
		# originally just for X; but no good on Solaris
		for X in "$@"; do echo "./$X"; done
		# for X; do echo "./$X"; done
	fi | grep -iv "/CVS/" | sed 's+^\.\/++' > $LOCALLIST

	echo
	printf "# "
	cursecyan
	printf "Local directories not in repository:"
	cursenorm
	printf "\n"

	find . -type d |
	grep -iv "/CVS" |
	sed 's+^\.\/++' |
	while read D
	do
		if test ! -d "$D/CVS"
		then
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
		sed "s+^+cvs add +"

	echo
	printf "# "
	cursecyan
	printf "Repository files missing locally:"
	cursenorm
	printf "\n"
	jfcsh $REPOSLIST $LOCALLIST |
		sed "s+^+cvs $SUGGEST +"

fi

echo

jdeltmp $REPOSLIST $LOCALLIST

exit 0
