#!/bin/sh
# For unix tar lacking the z option
ZIPFILE="$1"
shift
gunzip -c "$ZIPFILE" | tar xf - "$@"
