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

# cvsdiff [-all] [-del] [<files>]

CHECKALL=
SUGGEST="update"
while true; do
	case "$1" in
		-all)
			CHECKALL=true
		;;
		-del)
			SUGGEST="remove"
		;;
		*)
			break
		;;
	esac
	shift
done

if test "$1" = "-all"; then
	CHECKALL=true
	shift
fi

PRE=`cat CVS/Root | afterlast ":"`"/"`cat CVS/Repository`"/"

echo
cursecyan
echo "Status of files compared to repository:"
cursegrey

cvs -q status "$@" | egrep "(^File:|Repository revision:)" |
	# sed "s+File:[	 ]*\(.*\)[	 ]*Status:[	 ]*\(.*\)+\1:\2+" |
	sed "s+.*Status:[	 ]*\(.*\)+\1+" |
	sed "s+[	 ]*Repository revision:[^/]*$PRE\(.*\),v+\1+" |
	while read X; do
		read Y;
		echo "$Y	# "`curseyellow`"$X"`cursegrey`
		echo "./$Y" >> /dev/stderr
	done 2> /tmp/in-repos.txt |
	grep -v "Up-to-date"

if test $CHECKALL; then

	# jfc nolines /tmp/local.txt /tmp/in-repos.txt |
		# sed "s+^./+cvs add ./+"

	if test "$1" = ""; then
		find . -type f
	else
		# originally just for X; but no good on Solaris
		for X in "$@"; do echo "./$X"; done
		# for X; do echo "./$X"; done
	fi | grep -iv "/CVS/" > /tmp/local.txt

	echo
	cursecyan
	echo "Local directories not in repository:"
	cursegrey

	find . -type d |
	grep -v "/CVS" |
	while read D; do
		if test ! -d "$D/CVS"; then
			echo "cvs add $D"
		fi
	done

	echo
	cursecyan
	echo "Local files not in repository:"
	cursegrey

	jfcsh /tmp/local.txt /tmp/in-repos.txt |
		sed "s+^./+cvs add ./+"

	echo
	cursecyan
	echo "Repository files missing locally:"
	cursegrey
	jfcsh /tmp/in-repos.txt /tmp/local.txt |
		sed "s+^./+cvs $SUGGEST ./+"

fi

echo

exit 0
