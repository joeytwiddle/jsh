#!/usr/bin/env bash
set -e

find node_modules/ -name typescript.js |
xargs -d '\n' grep -l 'var defaultMaximumTruncationLength = [0-9]*;' |
while read file
do sed -i 's/var defaultMaximumTruncationLength = [0-9]*;/var defaultMaximumTruncationLength = 1000;/' "$file"
done

# Show new version, for verification:
find node_modules/ -name typescript.js | xargs -d '\n' grep 'var defaultMaximumTruncationLength = [0-9]*;'
