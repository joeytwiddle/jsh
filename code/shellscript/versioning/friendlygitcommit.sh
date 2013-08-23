#!/bin/bash

# BUG: Only works from the root of the repository, fails in subfolders!

exec 3>&0   # Save user stdin(0) into 3

# Get list of modified files
git status --porcelain |
grep "^ M " |
sed 's+^ M ++' |

while read FILE
do

	git diff "$FILE" | diffhighlight

	# Save stdin (the stream of filenames) into 4
	exec 4>&0
	# Read from original user's stdin (we saved in 3)
	exec <&3

	while true
	do

		echo
		echo "Would you like to: (A)dd to staged commit ?  [Enter] to (S)kip, (Q)uit, or enter a message to commit."

		read cmd

		case "$cmd" in
			q|Q)
				echo "User requested exit."
				exit 0
			;;
			c|C|a|A|.)
				verbosely git add "$FILE"
				break # out of UI while and continue FILE read
			;;
			???*)
				verbosely git add "$FILE"
				msg="$cmd"
				verbosely git commit -m "$msg"
				#commit_messasge="$commit_messasge| $msg "
				break
			;;
			""|s|S)
				echo "Doing nothing with $FILE"
				break # out of UI while and continue FILE read
			;;
		esac

	done

	echo
	sleep 1

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

