#!/usr/bin/env bash

#browse "https://gist.github.com/piscisaureus/3342247#gistcomment-1292509"

# From https://gist.github.com/chernjie/b16fe4dccf3f386d52ff
# NOTE: This operates on all remotes, although usually we only need it for 'origin'.
# TODO: Should really arrange the two entries in reverse, as mentioned in #gistcomment-1292509 above.
git remote -v | grep fetch | grep github | \
    while read remote url _; do
        if ! git config --get-all "remote.$remote.fetch" | grep -q refs/pull
        then
            git config --add "remote.$remote.fetch" \
                '+refs/pull/*/head:refs/remotes/'"$remote"'/pull/*'
        fi
    done

# If you want to remove the PR branches, remove the entry/entries that were added to `.git/config` and then:
#
#     git fetch --all --prune
