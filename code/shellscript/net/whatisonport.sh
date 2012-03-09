#!/bin/sh

# Meh.  We get this message when using sudo, because UID remains unchanged.
[ "$UID" = 0 ] || echo "You probably need to be root."

PORT="$1" ## For multiple, separate with ','s.
fuser -v "$PORT"/tcp
