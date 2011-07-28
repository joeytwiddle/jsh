#!/bin/sh

if [ "$1" = -m ]
then COMMIT_MESSAGE="$2" ; shift ; shift
fi

git status "$@" | grep "^#[ 	]*modified:[ 	]*" | dropcols 1 2 |
withalldo -r verbosely git add

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
withalldo -r verbosely git add

git status "$@" | grep "^#[ 	]*deleted:[ 	]*" | dropcols 1 2 |
withalldo -r verbosely git rm

# verbosely git commit -m "`geekdate`" "$@"
if [ "$COMMIT_MESSAGE" ]
then verbosely git commit -m "$COMMIT_MESSAGE" "$@"
else verbosely git commit "$@"
fi

