#!/bin/sh

#find "$HOME/" -type d -name .git |
locate -r '/\.git$' | grep -F -e "$HOME/" |

grep -v "/PORRIDGE_BACKUP_INCOMPLETE/" |
grep -v "/porridge_home/" |
grep -v "/mnt/" |
grep -v "/strato/" |
grep -v "/rc_files.from_strato/" |

#cat ; exit

sed 's+/\.git$++' |

while read repo_folder
do
	echo "### $repo_folder"

	cd "$repo_folder" || continue

	# Consider: Skip this repo if .git/config does not contain a nice URL.  E.g. accept only https://username@...

	git fetch --all # --verbose

	echo

	sleep 1
done

