#!/bin/sh

if [ "$1" = --help ]
then
	echo
	echo "gitautocommit <git_options>"
	echo
	echo "  will stage and commit all changed files under the current directory."
	echo
	echo "  Without the -m option, you will see a preview of the changes, which won't be"
	echo "  committed if you do not add a message."
	echo
	echo "  Files to always ignore are currently specified by regexps within this script."
	echo
	exit 1
fi

if [ "$1" = -m ]
then COMMIT_MESSAGE="$2" ; shift ; shift
fi

git status "$@" | grep "^#[ 	]*modified:[ 	]*" | dropcols 1 2 |
withalldo -r verbosely git add

pipeboth=cat
[ "$VERBOSE" ] && pipeboth=pipeboth

[ "$VERBOSE" ] && jshinfo "Adding:"
# git status "$@" | fromline "^# Untracked files:$" | grep "^#	" | dropcols 1 |
## This was insatisfactory, listing the top missing folder and nothing below it.  So let's focus on files...
find . -type f |
## Files we do not want to store:
grep -v "\(^\|/\)[.].*[.]sw.$" | ## Vim swapfiles
grep -v "[.]class$" | ## Java classfiles
grep -v "/CVS/" | ## CVS folders
grep -v "/[.]git/" | ## git itself!
grep -v "/build/.dependency-info/" | ## Build files (Eclipse?)
grep -v "/[.]gqview/" | ## Was randomly in my fuse-j-sh project
grep -v "\.recovered\.[0-9]*$" |
$pipeboth |
withalldo -r verbosely git add
echo

[ "$VERBOSE" ] && jshinfo "Removing:"
git status "$@" | grep "^#[ 	]*deleted:[ 	]*" | dropcols 1 2 |
$pipeboth |
withalldo -r verbosely git rm
echo

# verbosely git commit -m "`geekdate`" "$@"
if [ "$COMMIT_MESSAGE" ]
then verbosely git commit -m "$COMMIT_MESSAGE" "$@"
else verbosely git commit "$@"
fi

