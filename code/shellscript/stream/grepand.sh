#!/usr/bin/env bash

next_pattern="$1"
shift

if [ "$#" -gt 0 ]
then exec grep -e "$next_pattern" | grepand "$@"
else exec grep -e "$next_pattern"
fi
