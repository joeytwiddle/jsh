#!/usr/bin/env bash

# This script will add an extra line to your `.git/config` that will also fetch
# pull request branches from GitHub, making it easy to test them.
#
# Note that if you want to make some amendments, you will not be able to push
# back to these branches, like you can when you add forks as remotes.
#
# From here: https://gist.github.com/piscisaureus/3342247

# See also: A perl tool to help manage PRs from the command line:
#
# https://github.com/robinsmidsrod/App-GitHubPullRequest

# There is sometimes a bug (fixed now?) which can be solved by putting the PR
# line before the normal fetch line:
#
# https://gist.github.com/piscisaureus/3342247#gistcomment-776888 (bash script)
#
# https://gist.github.com/piscisaureus/3342247#gistcomment-1292509

# https://github.com/jasoncodes/dotfiles/blob/a29509902cb839b6aaf26d2d5409d66199b86d1d/shell/aliases/git.sh#L93-L110

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
