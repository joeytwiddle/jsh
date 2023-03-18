#!/bin/bash

# Adding and committing only works from the root of the repository.  It fails if run in a subfolder.
gitTopLevelDir=$(git rev-parse --show-toplevel)
# But we don't move into the root folder until later, so that e.g. '.' can be passed as an argument and given to `git status`.

exec 3>&0   # Save user stdin(0) into 3

if [ "$1" = -all ]
then
	catch_untracked_files="\|??"
	shift
fi

# Get list of modified files
git status --porcelain "$@" |
# ' M' is a normal modified file
# 'MM' means it has been staged, but there are modifications since the staged version
# 'UU' is unmerged paths (after a merge conflict, files that should be or were fixed).  However BUG these *cannot* be committed individually, they must be committed along with any other files in the merge which did not conflict.
grep "^\( M\|UU\|MM${catch_untracked_files}\) " |
sed 's+^.. ++' |
sed 's+^"\(.*\)"$+\1+' |

while read FILE
do

	cd "$gitTopLevelDir"

	git diff "$FILE" | diffhighlight

	# Save stdin (the stream of filenames) into 4
	exec 4>&0
	# Read from original user's stdin (we saved in 3)
	exec <&3

	while true
	do

		echo
		add_command="A"
		if command -v aicommits >/dev/null 2>&1
		then add_command="A/AI"
		fi
		jshquestion "Enter a message to add and commit, or (${add_command}) to stage, (S)kip/<Enter>, (E)dit the file, (R)eset it, or (Q)uit? "

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
				then aicommits -g 3
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
			""|s|S|n|N)
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

