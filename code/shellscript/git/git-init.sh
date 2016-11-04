#!/bin/sh
# I like to initialise the repo with an empty commit, so that I can fixup the
# first real commit later, or rewind and cherry-pick from scratch.
git init &&
git commit --allow-empty -m "-- empty commit --"
