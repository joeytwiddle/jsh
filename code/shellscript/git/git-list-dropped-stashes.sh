#!/usr/bin/env sh

# Whoops did you just pop a stash and then lose the changes with an accidental reset?  Don't panic, that stash is probably still in history.

# TODO: Would be nice to sort them into reverse-date order

git show -p $(memo git fsck --no-reflog | awk '/dangling commit/ {print $3}')
