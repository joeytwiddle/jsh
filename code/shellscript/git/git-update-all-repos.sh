#!/bin/sh

# Finds all the git repos under your home folder, and tries to fetch them,
# so you will have the latest upstream the next time you visit the folder.
#
# See also: https://gist.github.com/douglas/1287372

COLLECT_DIRTY_REPOS=1
if [ -n "$COLLECT_DIRTY_REPOS" ]
then printf '' > ~/src/repos_with_changes.list
fi

echo "# Starting at $(date)"

#ALSO_RUN_GIT_GC=1

# For some reason, locate on macOS was not scanning /Users folders
if [ "$(uname)" = Darwin ]
then find "$HOME/" -type d -not '(' '(' -name Library -o -name .Trash -o -name homebrew -o -name node_modules ')' -prune ')' -name .git
else locate -r '/\.git$'
fi |

fgrep "$HOME/" |

fgrep -v "/.Trash/" |
fgrep -v "/node_modules/" |
fgrep -v "/.nvm/" |
fgrep -v "/.cache/" |
fgrep -v "/jspm-cache/" |
fgrep -v "/porridge_home/" |
fgrep -v "/mnt/" |
fgrep -v "/strato/" |
fgrep -v "/rc_files.from_strato/" |

#cat ; exit

sed 's+/\.git$++' |

while read repo_folder
do
	echo "### $repo_folder"

	cd "$repo_folder" || continue

	# Consider: Skip this repo if .git/config does not contain a nice URL.  E.g. accept only https://username@...

	git fetch --all # --verbose

	if [ -f ".git/git-bug" ] && which git-bug >/dev/null 2>&1
	then
		git-bug pull
		git-bug bridge pull
	fi

	[ -n "$ALSO_RUN_GIT_GC" ] && git gc

	if [ -n "$COLLECT_DIRTY_REPOS" ]
	then
		if git status --porcelain | grep . >/dev/null
		then
			echo "$repo_folder" >> ~/src/repos_with_changes.list
		fi
	fi

	echo

	sleep 1
done 2>&1 |

# This awk script keeps only those blocks which are interesting
# It hides boring blocks (nothing was pulled, or just a password error)
# f indicates when we have found a block, and we are recording the lines into rec
# i indicates that we have detected an interesting block (or at least a not known-boring block)
# p indicates that there was a password error, so the block isn't interesting after all
awk '
	/^###/ {rec=""; f=1; i=0; p=0}
	!f {print $0}
	f {rec = rec $0 ORS}
	f && !/^###/ && !/^Fetch/ && !/^$/ {i=1}
	f && /could not read Password/ {p=1}
	/^$/ {if (f && i && !p) printf "%s", rec; f=0}
'

echo "# Finished at $(date)"
