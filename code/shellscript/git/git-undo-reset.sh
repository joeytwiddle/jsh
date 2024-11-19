#!/usr/bin/env bash
set -e

#echo "Try git show on the following commits or blobs:"
#echo
#verbosely git fsck --lost-found

# I tried formatting the output, but it didn't list everything.
# I'm not sure for-each-ref is the right thing to use.  I think that only works on branches?
#     hashes="$(memo git fsck --lost-found | cut -d' ' -f 3)" ; git for-each-ref --sort=committerdate --format="%(refname) (%(refname:short)) ${author_color}%(committerdate:relative) (%(authorname)) -${reset_color} ${subject_color}%(subject)${reset_color}" ${hashes}

# Another script attempt.  Better, but I would like to add the sorting.
#     git fsck --lost-found | grep -o '\<[0-9a-z]*$' | TODO_sort_blobs_by_date | while read blob; do git show --color=always "$blob"; done | less -RX

(
  echo "I will first show you dangling commits, then dangling blobs"
  echo
  echo "You may search for '# blob' to jump to the latter"
  echo

  # You can view dangling commits with
  git-list-dropped-stashes

  # For dangling blobs:
  list_of_blobs="$(memo git fsck --lost-found | awk '/dangling blob/ {print $3}')"

  for blob in $list_of_blobs
  do
    echo "# $(curseyellow;cursebold)blob ${blob}$(cursenorm)"
    echo
    git show "$blob"
    echo
  done
) |
less -RX
