#!/bin/bash

# Meh.  We get this message when using sudo, because UID remains unchanged.
# Meh.  Now getting this even when logged in as root and already started jsh.  Ok changing shebang from sh to bash fixed that.
[ "$UID" = 0 ] || echo "You probably need to be root."

PORT="$1" ## For multiple, separate with ','s.
fuser -v "$PORT"/tcp
