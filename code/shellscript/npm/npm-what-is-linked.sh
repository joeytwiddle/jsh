#!/usr/bin/env bash
set -e

# Find the node_modules folder
npm_root="$(npm root)"

if ! [ -d "$npm_root" ]
then
	echo "npm root '${npm_root}' is not a folder" >&2
	exit 1
fi

cd "$npm_root"

find . -maxdepth 2 -not \( -name '.bin' -prune \) -type l -print0 |
	xargs -0 -r ls -l --color
