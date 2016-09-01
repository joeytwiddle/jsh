#!/bin/sh

# But I really want to remove the merged branches on remote too
verbosely git branch --delete $(git branch --merged | grep -v '^\*' | grep -v '\smaster$')
