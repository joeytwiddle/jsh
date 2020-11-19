#!/bin/sh

# Finds all the git repos under your home folder, and tries to fetch them,
# so you will have the latest upstream the next time you visit the folder.
#
# See also: https://gist.github.com/douglas/1287372

#ALSO_RUN_GIT_GC=1

#find "$HOME/" -type d -name .git |
locate -r '/\.git$' |

fgrep "$HOME/" |

sed 's+/\.git$++' |

fgrep -v "/porridge_home/" |
fgrep -v "/mnt/" |
fgrep -v "/strato/" |
fgrep -v "/rc_files.from_strato/" |
fgrep -v "/.cache/" |
grep -v "/jspm-cache$" |
grep -v "/\.nvm$" |

#cat ; exit

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
