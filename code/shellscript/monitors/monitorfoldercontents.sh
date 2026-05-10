#!/usr/bin/env bash
set -e

target_folder="$1"

cd "$target_folder"
jwatch eval "find . -type f | withalldo grep ."

# Interferes with red/white changes
#| highlight '^[^:]*'
