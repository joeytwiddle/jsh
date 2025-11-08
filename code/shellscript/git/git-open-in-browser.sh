#!/usr/bin/env bash
set -e

if ! command -v open_in_browser >/dev/null 2>&1
then
	open_in_browser() {
		local url="$1"
		if command -v xdg-open >/dev/null 2>&1; then
			# Linux
			xdg-open "$url"
		elif command -v open >/dev/null 2>&1; then
			# macOS
			open "$url"
		elif command -v start >/dev/null 2>&1; then
			# Windows (Git Bash/Cygwin)
			start "$url"
		else
			echo "Could not find a command to open the browser. URL is:"
			echo "$url"
			exit 1
		fi
	}
fi

file_path="$1"

if [ -z "$file_path" ]
then
	#echo "Error: No file provided" >&2
	#exit 1
	# Open root folder
	# Actually easier, open current folder
	file_path=.
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1
then
	echo "Error: Not in a Git repository" >&2
	exit 1
fi
# Find the top-level directory of the git repository
git_topdir="$(realpath "$(git rev-parse --show-toplevel)")"

# Compute the relative path from the git root to the file
absolute_file_path="$(realpath "$file_path")"
#file_path="${absolute_file_path#$git_topdir}"
file_path="$(printf "%s\n" "$absolute_file_path" | sed "s+^${git_topdir}++")"
# file_path should now begin with '/'

# Usually origin
primary_remote="$(git remote | head -n 1)"
remote_url="$(git config --get "remote.${primary_remote}.url")"

# Determine trunk_branch
if git rev-parse --verify --quiet "${primary_remote}/main" > /dev/null
then trunk_branch="main"
elif git rev-parse --verify --quiet "${primary_remote}/master" > /dev/null
then trunk_branch="master"
else
	echo "Error: Could not find the trunk branch" >&2
	exit 1
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" = HEAD ]
then
	current_branch="$trunk_branch"
	echo "Note: Since you are not on a branch, we will use branch '${trunk_branch}'" >&2
fi

# TODO: Add support for *gitlab* and *bitbucket*

# Convert: git@github.com:owner/repo.git -> https://github.com/owner/repo
# Convert: https://github.com/owner/repo.git -> https://github.com/owner/repo
github_base_url="$(echo "$remote_url" | sed -E 's/^(git@|https:\/\/)([^/:]+)[:/](.+)$/https:\/\/\2\/\3/ ; s/(\.git|)\/*$//')"

# If they just want the root of the repo then we can go to the top of the repo
if ( [ "$trunk_branch" = "main" ] || [ "$trunk_branch" = "master" ] ) \
	&& \
	( [ "$file_path" = "/" ] || [ "$file_path" = "." ] || [ "$file_path" = "" ])
then url_path="/"
else url_path="/blob/${current_branch}${file_path}"
fi
# CONSIDER: We could also check if they are opening the README, but in that case we would need to tell the browser to jump down the page, past the files, to show the README
# || [ "$file_path" = "/README" ] || [ "$file_path" = "/README.txt" ] || [ "$file_path" = "/README.md" ]

url="${github_base_url}${url_path}"

echo "Opening ${url}..."
open_in_browser "$url"
