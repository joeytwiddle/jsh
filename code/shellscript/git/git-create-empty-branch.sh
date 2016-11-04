#!/bin/sh
exec git checkout --orphan "$@"

# Steps to create an empty branch:
#
#   git checkout --orphan _empty_
#   git reset --hard
#   git commit --allow-empty -m "empty"
