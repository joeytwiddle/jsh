#!/bin/bash

set -e

[ -d node_modules ] || exit 4

store_folder="node_modules/.store"
#store_folder="$HOME/.npm/.store"
#store_absolute=true

mkdir -p "$store_folder"

size_before=$(du -sh node_modules)

find ./node_modules/ -type d |
grep '/node_modules/[^/]\+$' |
# Skip everything immediately below the .store, but allow folders below it
grep -v 'node_modules/.store/[^/]\+$' |
# These are littered around but they aren't modules
grep -v 'node_modules/\.bin$' |
# Skip all hidden files in node_modules folders
grep -v 'node_modules/\.[^/]*$' |

#cat ; exit

# Do deepest children first
sort | reverse |

while read module_path
do
	module_name=$(echo "$module_path" | sed 's+.*/++')

	# Find the module version
	module_version=$(grep -o '^\s*"version"\s*:\s*"[^"]*"' "$module_path/package.json" | sed 's+.*:\s*"++ ; s+"\s*\s*$++')
	if [[ -z "$module_version" ]]
	then
		# Find the most recent file in the module (this includes descending into child modules)
		file=$(find "$module_path"/ -type f -printf "%T@ %p\n" | sort -n -k 1 | tail -n 1 | sed 's+^[^ ]* *++')
		[[ -z "$file" ]] && file="$module_path"
		date=$(TZ=UTC date +"%Y%m%d-%H%M%S" -r "$file")
		module_version="utc${date}"
	fi

	full_package_name="$module_name@$module_version"
	echo "# $full_package_name is at $module_path"

	target_path="$store_folder/$full_package_name"

	# If we could symlink from module_path to target_path, what is the relative path?
	depth=$(echo "$module_path" | grep -o / | wc -l)
	depth=$((depth - 2))
	relative_target=$(yes "../" | head -n $depth | tr -d '\n')".store/$full_package_name"

	if [ ! -e "$target_path" ]
	then
		echo "Moving and linking $full_package_name from $module_path to $target_path"
		mv "$module_path" "$target_path"
		ln -s "$relative_target" "$module_path"
	else
		echo "There is already this package at the target $target_path"
		if diff -r "$target_path" "$module_path"
		then
			echo "Target is identical to module, so removing and linking module."
			rm -rf "$module_path"
			ln -s "$relative_target" "$module_path"
		else
			echo "Not flattening $module_path because it doesn't match the target."
			echo
		fi
	fi
done

size_after=$(du -sh node_modules)

echo "Before: $size_before"
echo "After: $size_after"
