#!/bin/zsh

##
## Using zsh shebang so that **/* works later on.  Could fix that up for bash
## at some point.
##
## NOTE: find . | withalldo is not quite the same - it will recurse down into
## .git folders which **/* doesn't.  That would be BAD!
##
## BUG: It recurses down into CVS folders anyway!  We could start with:
##
##   | egrep -v '/(CVS|.git|.....)/' |
##
## But NOTE that open_recent_files has a beginning of a list "ignore_non_source_files"!
## Recommend combining efforts there rather that advancing independently.
##

## One danger with refactoring is if the target word already exists, then it
## cannot be undone later!
## TODO: Check for the target word over the target files, and warn the user if
## it is already used!

echo "Warning: This script is about to do a lot of things to all the files under your current folder!  Are you sure you want to proceed?  I recommend making a backup first."
read answer
if [ "$answer" != y ]
then
	exit 0
fi

cat << !
Note: it's only an atom if you put \< \> on yourself!
Perhaps it would be better to take an option to leave them off.  :P
!

sedreplace -changes -nonochanges "$1" "$2" **/*

renamefiles "$1" "$2" **/* | bash -x

## |sh -x sometimes gets the wrong PS1/4 (e.g. bash runs with my zsh shell's PS1/4)

