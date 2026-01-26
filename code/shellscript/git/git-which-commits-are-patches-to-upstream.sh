#!/usr/bin/env bash
set -e

# CAVEATS:
# Just because a commit message matches, does NOT mean these were once the same commit.
# For example, many repos may make multiple commits with the same commit message, such as "Bump version number" or "Fix formatting".

# List all local commits not on the upstream, but exclude those which are cherry-picks
git log --cherry-mark --right-only --oneline @{upstream}...HEAD | grep -v '^=' |

# For each unique local commit, does the commit message match a commit message on the remote?
while IFS=' ' read marker commit_hash commit_msg
do
  if git log @{u} --grep="$commit_msg" | grep . >/dev/null
  then
    # This commit message appears on the remote, but the patch must be different (since it wasn't marked as a cherry-pick)
    # Therefore it is most likely a tweak of the upstream commit
    #echo "$commit_hash"
    upstream_commit_hash="$(git log @{u} --grep="$commit_msg" -n 1 --pretty | head -n 1 | takecols 2)"
    echo "Local commit ${commit_hash} is probably a rework of upstream commit ${upstream_commit_hash}"
    git log --pretty --oneline -n 1 "$commit_hash"
  fi
done
