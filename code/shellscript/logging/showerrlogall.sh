#!/bin/bash
# From: http://unix.stackexchange.com/questions/91779/what-is-the-name-of-the-shell-feature-tee-copyerror-txt-2
"$@" 1> stdout.log 2> >(tee stderr.log >&2)
