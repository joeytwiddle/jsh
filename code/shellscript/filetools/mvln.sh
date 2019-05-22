#!/usr/bin/env bash
set -e

# BUG TODO: Fails to do the ln if one of the nodes has a trailing slash, e.g. "a_folder/"
# TODO: Makes an ugly link (with double "//") if the last arg has a trailing slash

if [ -z "$1" ] || [ -z "$2" ] || [ "$1" == --help ]
then
	cat <<- !
		
		mvln <nodes_to_move>... <destination_dir>
		
		  will move the files/dirs into the destination dir,
		  then make a symlink to the new location.
		
	!
	exit 0
fi

target_dir="$(lastarg "$@")"

if [ ! -d "$target_dir" ]
then . errorexit "Last arg should be a directory"
fi

for node in "$@"
do
	# Skip the last arg when we reach it
	[ "$node" = "$target_dir" ] && continue
	verbosely mv "$node" "$target_dir"/ &&
	verbosely ln -s "$target_dir/$(filename "$node")" "$(dirname "$node")/$filename"
done
