#!/usr/bin/env bash
set -e

# From: https://stackoverflow.com/questions/1753070/how-do-i-configure-git-to-ignore-some-files-locally

git_root_folder="$(git rev-parse --show-toplevel)"

echolines "$@" >> "$git_root_folder"/.git/info/exclude
