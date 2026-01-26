#!/usr/bin/env bash
set -e

git rev-list --cherry "HEAD...@{u}" | grep '^=' | sed 's/^=//' |
while read commit
do git log --pretty --oneline -n 1 "$commit"
done
