#!/usr/bin/env bash
set -e

npm_root="$(npm root)"

if ! [ -d "$npm_root" ]
then exit 1
fi

cd "$npm_root"

find . -maxdepth 2 -not \( -name '.bin' -prune \) -type l -print0 |
	xargs -0 -r ls -l --color
