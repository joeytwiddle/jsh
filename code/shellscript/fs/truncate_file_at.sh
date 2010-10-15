#!/bin/sh
## Can also be used to expand a file with zero-bytes (possibly creating a sparse file)

FILE="$1"
POSITION="$2"

## TODO: If position ends in [GgMmKkBb] multiply it by 1024^n respectively.

dd if=/dev/zero of="$FILE" bs=1 count=0 seek="$POSITION"
