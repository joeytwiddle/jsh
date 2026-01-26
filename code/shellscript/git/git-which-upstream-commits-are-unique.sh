#!/usr/bin/env bash
set -e

git rev-list "HEAD..@{u}" |
while read commit
do git log --pretty --oneline -n 1 "$commit"
done
# TODO
