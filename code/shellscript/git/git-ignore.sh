#!/usr/bin/env bash
set -e

git_root_folder="$(git rev-parse --show-toplevel)"

echolines "$@" >> "$git_root_folder"/.gitignore
