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

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1
then
	echo "Error: Not in a Git repository" >&2
	exit 1
fi

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
	echo "Error: Not on a branch" >&2
	exit 1
fi

# TODO: Add support for *gitlab* and *bitbucket*

# Convert: git@github.com:owner/repo.git -> https://github.com/owner/repo
# Convert: https://github.com/owner/repo.git -> https://github.com/owner/repo
github_base_url="$(echo "$remote_url" | sed -E 's/^(git@|https:\/\/)([^/:]+)[:/](.+)$/https:\/\/\2\/\3/ ; s/(\.git|)\/*$//')"

# It is difficult to know whether a PR exists, but if we open the compare page, GitHub will provide a link to the PR

# Format: https://github.com/OWNER/REPO/compare/default_branch...current_branch
#url="${github_base_url}/compare/${trunk_branch}...${current_branch}"
# Format: https://github.com/OWNER/REPO/pull/new/current_branch
# This opens a create new branch page if the PR does not already exist, but if it does exist, you get basically the same compare page as above
url="${github_base_url}/pull/new/${current_branch}"

echo "Opening ${url}..."
open_in_browser "$url"
