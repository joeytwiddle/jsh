#!/bin/bash

# Examines all packages in ./node_modules folder, and moves any which can be
# moved into a flat store of modules at:
#
#     ./node_modules/.store/<module_name>@<version>
#
# or to a global store folder at:
#
#     ~/.npm-store/<module_name>@<version>
#
# A symlink is placed at the original module location, pointing to the new
# location.
#
# If a module with matching name and version already appears in the flat store,
# it will be linked to only if the packages match exactly.

# BUG: Although this script comes pretty close to its goal, it is actually
# useless, because it seems node's require() will not follow symlinks!
#
#                                               *children_last*
# When we move a folder whose child modules have already been processed, we
# will likely break the relative symlinks of the child modules.  To avoid this,
# we no longer process children first, now we process them last!
#
# BUG: But since we proceed to process children which are now below symlinks
#      (find has already queued them), we calculate the wrong relative paths
#      for them (because their true path is different)!
#
#      This could be avoided by expanding the module_path (resolving links to
#      find the location in the store) before calculating the depth, although
#      we still want module_path relative to `.`, not absolute.
#
#      Or more simply, we can assume that all modules will end up in the store,
#      and therefore the store will always be two levels above any inner
#      node_modules folder.  I.e. all links will be
#
#        ../../<module_name>@<version>
#
#      But for now, we avoid this issue by using the global store, which uses
#      absolute symlinks.
#
# TODO: It seems `diff -r` compares the targets of symlinks, which is
#       expensive, and not actually what we want.  Ideally it should compare
#       the target paths of the two links, like Git does.

set -e

if [ ! -d node_modules ]
then
	echo "I need to see ./node_modules but I can't!"
	exit 4
fi

use_global_store=1

if [ -n "$use_global_store" ]
then store_folder="$HOME/.npm-store"
else store_folder="node_modules/.store"
fi

mkdir -p "$store_folder"

size_before=$(du -sh node_modules)
store_size_before=$(du -sh "$store_folder")

# Find module folders that we might be able to store in our flat folder
find ./node_modules/ -type d |
grep '/node_modules/[^/]\+$' |
# Skip all hidden files in node_modules folders (including node_modules/.store and **/node_modules/.bin)
grep -v 'node_modules/\.[^/]*$' |
# Skip everything immediately inside the .store, but check for modules deeper below it
# (Although it is quite likely that these cannot be stored, or they would have already been stored on the first pass.)
grep -v 'node_modules/\.store/[^/]\+$' |

grep xtend |

# Just show the list of modules that will be considered; don't do anything.
#cat ; exit

sort |
# Process deepest children first.  (NO!  See |children_last| above for why.)
#reverse |

while read module_path
do
	module_name=$(echo "$module_path" | sed 's+.*/++')

	# Find the module version
	module_version=$(grep -o '^\s*"version"\s*:\s*"[^"]*"' "$module_path/package.json" | sed 's+.*:\s*"++ ; s+"\s*\s*$++')
	if [[ -z "$module_version" ]]
	then
		# Find the most recent file in the module (this includes descending into child modules)
		# Use the date of this file to create a fake "version"
		file=$(find "$module_path"/ -type f -printf "%T@ %p\n" | sort -n -k 1 | tail -n 1 | sed 's+^[^ ]* *++')
		[[ -z "$file" ]] && file="$module_path"
		date=$(TZ=UTC date +"%Y%m%d-%H%M%S" -r "$file")
		module_version="utc-${date}"
	fi

	full_package_name="$module_name@$module_version"
	#echo "# $full_package_name is at $module_path"

	target_path="$store_folder/$full_package_name"

	# If we could symlink from module_path to target_path, what is the relative path?
	# But for global store, use absolute path.
	if [ -n "$use_global_store" ]
	then relative_target="$store_folder/$full_package_name"
	else
		depth=$(echo "$module_path" | grep -o / | wc -l)
		depth=$((depth - 2))
		relative_target="$(yes "../" | head -n $depth | tr -d '\n').store/$full_package_name"
	fi

	if [ ! -e "$target_path" ]
	then
		echo "Moving and linking $full_package_name from $module_path to $target_path"
		mv "$module_path" "$target_path"
		ln -s "$relative_target" "$module_path"
		echo
	else
		echo "There is already a package at the target: $target_path"
		if diff -r "$target_path" "$module_path"
		then
			echo "Target is identical to module, so removing $module_path and linking it to $target_path"
			rm -rf "$module_path"
			ln -s "$relative_target" "$module_path"
			echo
		else
			echo "Not flattening $module_path because it doesn't match the target."
			echo
		fi
	fi
done

size_after=$(du -sh node_modules)
store_size_after=$(du -sh "$store_folder")

echo "node_modules before: $size_before"
echo "node_modules after:  $size_after"
echo "store before:        $store_size_before"
echo "store after:         $store_size_after"
