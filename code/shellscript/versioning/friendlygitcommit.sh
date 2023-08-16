#!/bin/bash

# Adding and committing only works from the root of the repository.  It fails if run in a subfolder.
git_toplevel_dir=$(git rev-parse --show-toplevel)
# But we don't move into the root folder until later, so that e.g. '.' can be passed as an argument and given to `git status`.

exec 3>&0   # Save user stdin(0) into 3

# Matches git add options
catch_untracked_files=""
if [ "$1" = --all ] || [ "$1" = -A ]
then
	catch_untracked_files="\|??"
	shift
fi

# Get list of modified files, and untracked files
git status --porcelain -u "$@" |
# ' M' is a normal modified file
# 'MM' means it has been staged, but there are modifications since the staged version
# 'UU' is unmerged paths (after a merge conflict, files that should be or were fixed).  However BUG these *cannot* be committed individually, they must be committed along with any other files in the merge which did not conflict.
grep "^\( M\|UU\|MM${catch_untracked_files}\) " |
sed 's+^.. ++' |
sed 's+^"\(.*\)"$+\1+' |
# Sometimes, despite -u, we can still get folders listed as untracked, if they are folders with a git project inside them
# We will just trim them out
grep -v '/$' |

while read FILE
do

	cd "$git_toplevel_dir"

	#git diff "$FILE" | diffhighlight
	#git diff --color "$FILE"
	git diff -w --word-diff=color "$FILE"

	if git status --porcelain "$FILE" | grep '^??' >/dev/null
	then
		# This is an untracked file, so the diff would have displayed nothing
		(
			echo "New file: $FILE"
			cat "$FILE" | highlight -bold '.*' green
		)
	fi

	# Save stdin (the stream of filenames) into 4
	exec 4>&0
	# Read from original user's stdin (we saved in 3)
	exec <&3

	while true
	do

		echo
		or_aicommits=""
		if command -v aicommits >/dev/null 2>&1
		then or_aicommits=" (or AI)"
		fi
		jshquestion "Enter a message${or_aicommits} to add and commit, or (A/Y) to stage, (Enter/N/D/S)kip, (E)dit the file, hard (R)eset it, or (Q)uit? "

		read cmd

		case "$cmd" in
			q|Q)
				echo "User requested exit."
				exit 0
			;;
			a|A|y|Y)
				echo
				verbosely git add "$FILE"
				break # stop asking what to do; proceed to the next file
			;;
			ai|AI|aI|Ai)
				verbosely git add "$FILE"
				if command -v aicommits >/dev/null 2>&1
				then
					aicommits --type=conventional -g 3
					# In case aicommits failed (e.g. the user decided to abort with CTRL-C) we will unstage the current file, and move on to the next
					git reset --quiet -- "$FILE"
				else echo "Command 'aicommits' is not installed\!" >&2
				fi
				# BUG: If the user accepted aicommits request to commit, then we should break to move on to the next file.  But note that the user might not always do that.
			;;
			e|E)
				verbosely editandwait "$FILE"
				# TODO: re-diff here?
			;;
			r|R)
				verbosely git checkout -- "$FILE"
				break
			;;
			???*|.)
				verbosely git add "$FILE"
				msg="$cmd"
				verbosely git commit -m "$msg"
				break
			;;
			# We also recognise N and D, to match the keys used by `git add --patch`
			""|s|S|n|N|d|D)
				jshinfo "Doing nothing with $FILE"
				break
			;;
		esac

	done

	echo
	sleep 0.5

	# Now we have what we need, go back to reading files
	exec <&4

done

echo
echo "If you staged some commits, you still need to do:"
echo
echo "git commit"
echo
echo "  or"
echo
echo "git commit -m \"...\""
echo

