#!/usr/bin/env bash
set -e

echo "Try git show on the following commits or blobs:"
echo
verbosely git fsck --lost-found

# If you are looking for a lost stash, you may try this:
#     gitk --all $( git fsck --no-reflog | awk '/dangling commit/ {print $3}' )
# From here: https://stackoverflow.com/questions/89332/how-do-i-recover-a-dropped-stash-in-git

# I tried formatting the output, but I got fewer results that git fsck listed!
# I'm not sure for-each-ref is the right thing to use.  Maybe that only works on branhces?
#     hashed="$(memo git fsck --lost-found | cut -d' ' -f 3)" ; git for-each-ref --sort=committerdate --format="%(refname) (%(refname:short)) ${author_color}%(committerdate:relative) (%(authorname)) -${reset_color} ${subject_color}%(subject)${reset_color}" $hashes
