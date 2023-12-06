#!/usr/bin/env bash

# This script will add an extra line to your `.git/config` that will also fetch
# pull request branches from GitHub, making it easy to test them.
#
# Note that if you want to make some amendments, you will not be able to push
# back to these branches, like you can when you add forks as remotes.
#
# Explanation here:
# https://gist.github.com/piscisaureus/3342247
#
# But we currently use the implementation from here:
# https://gist.github.com/chernjie/b16fe4dccf3f386d52ff

# See also: A perl tool to help manage PRs from the command line:
#
# https://github.com/robinsmidsrod/App-GitHubPullRequest

# There used to be a bug which can be solved by putting the PR line before the
# normal fetch line:
#
# https://gist.github.com/piscisaureus/3342247#gistcomment-776888
#
# https://github.com/jasoncodes/dotfiles/blob/a29509902cb839b6aaf26d2d5409d66199b86d1d/shell/aliases/git.sh#L93-L110
#
# https://gist.github.com/piscisaureus/3342247#gistcomment-1292509
#
# But I think the bug has been fixed now, so we no longer need to worry.

# NOTE: This operates on all remotes, although usually we only need it for 'origin'.
git remote -v | grep fetch | grep github | \
    while read remote url _; do
        if ! git config --get-all "remote.$remote.fetch" | grep -q refs/pull
        then
            git config --add "remote.$remote.fetch" \
                '+refs/pull/*/head:refs/remotes/'"$remote"'/pull/*'
        fi
    done

#echo "Now run: git fetch --all"
# Actually, it's usually only origin that needs to be fetched
git fetch --all

# If you want to remove the PR branches, remove the "pull" entry/entries that were added to `.git/config` and then:
#
#     git fetch --all --prune
