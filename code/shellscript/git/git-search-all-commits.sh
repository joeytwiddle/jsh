#!/bin/sh
set -e

search_text="$1"

git log --all --grep="$search_text"
