#!/bin/sh
[ "$UID" = 0 ] || echo "You probably need to be root."
PORT="$1" ## For multiple, separate with ','s.
fuser -v "$PORT"/tcp
