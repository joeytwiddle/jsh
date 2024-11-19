#!/usr/bin/env sh

# Whoops did you just pop a stash and then lose the changes with an accidental reset?  Don't panic, that stash is probably still in history.

# From here: https://stackoverflow.com/questions/89332/how-do-i-recover-a-dropped-stash-in-git
list_of_commits="$(memo git fsck --no-reflog | awk '/dangling commit/ {print $3}')"

# Optional but useful: sort the commits into reverse date order
sorted_list="$(git show --pretty="%at %H" --no-patch ${list_of_commits} | sort -n -k 1 -r | awk '{print $2}')"

git show --color=always --stat -p ${sorted_list}
