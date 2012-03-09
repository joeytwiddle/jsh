#!/bin/bash

# TODO: I usually read gitdiff before doing gitautocommit, *but* gitdiff does
# not show what new files gitautocommit will add.  This sometimes causes
# accidental commits of naff files!  Perhaps after the brute-force add, we should
# ask git what the new files are, and if there are any, we should *inform* the
# user and ask for their permission if they requested an automatic commit (-m).

set -e
## I set this so we won't proceed with the commit if the "git add" fails, e.g.
## with "The following paths are ignored by one of your .gitignore files" and
## "fatal: no files added".

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

pipeboth=cat
[ "$VERBOSE" ] && pipeboth=pipeboth

jshinfo "Adding changed files" ## because we skipped verbosely below
[ "$VERBOSE" ] && jshinfo "Changed files:"
git status "$@" | grep "^#[ 	]*modified:[ 	]*" | dropcols 1 2 |
$pipeboth |
withalldo -r verbosely git add

jshinfo "Adding new files" ## because we skipped verbosely below
[ "$VERBOSE" ] && jshinfo "New files:"

# BUG TODO: The .gitignore file may be in a parent folder.  In fact we should
# probably concatenate all .gitignore files until we reach the .git root.
gitignoreExpr="none_of_your_files_look_like_this.noodles"
if [ -f .gitignore ]
then
	# sed 's+^+\\./+' | 
	gitignoreExpr="\(^\|/\)\($( cat .gitignore | globtoregexp | sed 's+$+\\|+' | tr -d '\n' | sed 's+\\|$++' )\)\(/\|$\)"
	# jshinfo "gitignoreExpr=$gitignoreExpr"
	## TODO: I don't think we have handled folders, i.e. /s and perhaps **s ?
fi

jshinfo "gitignoreExpr = $gitignoreExpr"

## This was insatisfactory, listing the top missing folder and nothing below it.
## If we want to commit recursively, let's focus on files...
find . -type f |
# sed 's+^\.\/++' |   ## This is for gitignoreExpr - fix that to remove this

## Files we do not want to store:

grep -v "$gitignoreExpr" |

grep -v "/[.]git/" | ## git itself!

# grep -v "\(^\|/\)[.].*[.]sw.$" | ## Vim swapfiles
# grep -v "[.]class$" | ## Java classfiles
# grep -v "/CVS/" | ## CVS folders
# grep -v "/build/.dependency-info/" | ## Build files (Eclipse?)
# grep -v "/[.]gqview/" | ## Was randomly in my fuse-j-sh project
# grep -v "\.recovered\.[0-9]*$" | ## recovervimswap files
# grep -v "\.js$" |   ## If you are hacking coffeescript

pipeboth |
# withalldo -r verbosely highlightstderr git add -f
withalldo -r highlightstderr git add -f
# For some reason git -f add does not always work on long lists of files/dirs,
# but adding them manually one-by-one can work!
echo

jshinfo "Removing files"
[ "$VERBOSE" ] && jshinfo "Removed files:"
git status "$@" | grep "^#[ 	]*deleted:[ 	]*" | dropcols 1 2 |
$pipeboth |
withalldo -r verbosely git rm || true
## We force return true atm because I would sometimes get:
##   "pathspec 'deleted_file.txt' did not match any files"
## perhaps because it had already been set for removal?
echo

set +e
## Now we might want to see there error exit code

# verbosely git commit -m "`geekdate`" "$@"
if [ "$COMMIT_MESSAGE" ]
then verbosely git commit -m "$COMMIT_MESSAGE" "$@"
else verbosely git commit "$@"
fi

if [ ! "$?" = 0 ]
then
	echo
	echo "If you do not want to commit what I have staged, you can clear the stage with:"
	echo "  git reset --mixed"
	echo
fi

## NOTES: I should have used git status --porcelain

