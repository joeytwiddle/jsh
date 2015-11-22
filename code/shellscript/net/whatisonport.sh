#!/bin/bash

PORT="$1"



# New method using netstat
# The regexp ensures we match the first (local) port not the second (remote) port.
# If run without being root, this can list ports opened by other users, but it won't actually list the PIDs or names of those processes.
# We could add -t and -u to restrict to TCP/UDP
netstat -anp --numeric-ports | grep ":${PORT}\>.*:"
exit



# Old method using fuser; slower and requires root for other owned processes!

# Meh.  We get this message when using sudo, because UID remains unchanged.
# Meh.  Now getting this message even when logged in as root and already started jsh.  Ok changing shebang from sh to bash fixed that.
[ "$UID" = 0 ] || echo "You probably need to be root."

# For multiple ports, you can separate with ','s.
fuser -v "${PORT}/tcp"
exit



# Alternative method using lsof (requires root for other owned processes)
lsof -P -S 2 -i "tcp:${PORT}" | grep "\(:${PORT}->.*:\|:${PORT} (LISTEN)$\)"
