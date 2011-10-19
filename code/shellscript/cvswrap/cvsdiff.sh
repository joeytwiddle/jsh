#!/bin/sh

# jsh-depends-ignore: after
# jsh-depends: cursecyan cursenorm cvsvimdiff afterlast jdeltmp jgettmp jfcsh jwhich

## BUG TODO: When your local checkout is not recently updated, we seem to get a
## shorter REPOSLIST than we should.
## This is because "cvs status" exits with something like:
## cvs [status aborted]: could not find desired version 1.5 in ...
## That is why we recommend cvsupdate -AdP before using cvsdiff

# . selfmemo -t 5minutes - "$0" "$@"; shift

if [ "$1" = -diff ] || [ "$*" = "" ]
then
	[ "$1" = -diff ] && shift
	# cvs diff | diffhighlight | more
	## cvs diff outputs progress on stderr, so we hide it
	cvs diff 2>/dev/null | diffhighlight | more +/"Index: "
	## This +/Index search means the user can press 'n' to scroll to the next
	## file, but it also means the first line is not displayed (better than the
	## whole first file though :)
	exit 0
fi

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
      ## These are all equivalent!
			# cvsvimdiff -all "$@"
			# cvscommit -vimdiff "$@"
			cvsvimdiffall "$@"
			exit
		;;
		-h|--help)
cat << !!!

cvsdiff
cvsdiff -diff <files/dirs>...

  With no arguments, or with -diff, shows a coloured diff of all the
  uncommitted changes.

cvsdiff [ -all | -del ] [ <files/dirs>... ]

  With arguments, or with -all or -del, displays a list of commands to commit
  the incoming and outgoing CVS changes.

  With -all suggests addition of new local files and folders.

  With -del suggests removal of new local files.  (Cleanup.)

  NOTE: cvsdiff only works properly after a cvs update (see TODO).

cvsdiff -vimdiff

  Performs a cvsvimdiff on each uncommited file using cvsvimdiffall (via
  cvsvimdiff and cvscommit).

  If you write the file during its session, it will be committed.

!!!
      exit 0
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

printf "" > $REPOSLIST

PARENT=.
cvs -z 5 status "$@" 2>&1 |
grep "\(^cvs \(status\|server\):\|^File:\)" |
	sed "
		s=^cvs \(status\|server\):[	 ]*Examining \(.*\)=PARENT \2=
		s=^File:[	 ]*\(no file\|\)\(.*\)[ 	]*Status:[	 ]*\(.*\)=\2 \3=
	" | # pipeboth |
	while read FNAME STATUS
	do
		while [ "$FNAME" = PARENT ]
		do
			# [ "$DEBUG" ] && debug "A `cursemagenta`$FNAME $STATUS`cursenorm`"
			PARENT="$STATUS"
			read FNAME STATUS
		done
		# [ "$DEBUG" ] && debug "B `curseblue`$FNAME $STATUS`cursenorm`"
		FILE="$PARENT/$FNAME"
		echo "$FILE	# "`curseyellow`"$STATUS"`cursenorm`
		echo "$FILE" | sed 's+^\.\/++' >> $REPOSLIST
	done |
	grep -v "Up-to-date" |
	sed '
		s|^\(.*Locally Added.*\)$|cvs commit \1|
		s|^\(.*Locally Removed.*\)$|cvs commit \1|
		s|^\(.*Locally Modified.*\)$|cvs commit \1|
		# s|^\(.*File had conflicts on merge.*\)$|cvs diff \1|
		s|^\(.*File had conflicts on merge.*\)$|cvsvimdiff \1|
		s|^\(.*Needs Patch.*\)$|cvs update \1|
		s|^\(.*Needs Merge.*\)$|cvs update \1|
		s|^\(.*Needs Checkout.*\)$|cvs update \1|
	' |
	if jwhich column quietly
	then column -t -s "	"
	else cat
	fi

if [ $CHECKALL ]
then

	# jfc nolines $LOCALLIST $REPOSLIST |
		# sed "s+^./+cvs add ./+"

	find "$@" -type f |
	# if [ ! "$1" ]
	# then
		# find . -type f
	# else
		# # originally just for X; but no good on Solaris
		# for X in "$@"; do echo "./$X"; done
		# # for X; do echo "./$X"; done
	# fi |
	grep -iv "/CVS/" | sed 's+^\.\/++' > $LOCALLIST

	echo
	printf "%s\n" "# `cursecyan`Local directories not in repository:`cursenorm`"

	find . -type d |
	grep -iv "/CVS" |
	sed 's+^\.\/++' |
	while read D
	do
		if [ ! -d "$D/CVS" ]
		then echo "cvs add $D"
		fi
	done

	echo
	printf "%s\n" "# `cursecyan`Local files not in repository:`cursenorm`"
	printf "\n"

	jfcsh $LOCALLIST $REPOSLIST |
		sed "s+^+cvs add +"

	echo
	echo "You might need to do cvsupdate or cvsupdate -AdP"
	# printf "# "
	# cursecyan
	# printf "Repository files missing locally:"
	# cursenorm
	# printf "\n"
	# jfcsh $REPOSLIST $LOCALLIST |
		# sed "s+^+cvs $SUGGEST +"

fi

echo

jdeltmp $REPOSLIST $LOCALLIST
# jshinfo "REPOSLIST=$REPOSLIST LOCALLIST=$LOCALLIST"

exit 0
