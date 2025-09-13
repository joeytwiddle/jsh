#!/usr/bin/env bash
set -e

#git ls-files |
find . -type f |
grep -v '/.git/' |
while read file
do
	# Gemini
	#commit_date=$(git log -1 --format="%ad" --date=format:"%Y-%m-%d %H:%M:%S" -- "$file")
	# qwen-coder
	timestamp=$(git log -n 1 --follow --format=format:%ct -- "$file")
	if [[ -n "$timestamp" ]]
	then verbosely touch -m -d "@$timestamp" "$file"
	fi
done
