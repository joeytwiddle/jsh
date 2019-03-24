#!/bin/bash

PORT="$1"



# This one works on macOS and on Linux
# But it requires root for processes owned by other users
if [ "$(uname)" = "Darwin" ]
then
    lsof -P -S 2 -i "tcp:${PORT}" | grep "\(:${PORT}->.*:\|:${PORT} (LISTEN)$\)"
    exit "$?"
fi



# New method using netstat
#
# See also: ss -tunapl (socket statistics) on https://twitter.com/nikethan/status/1090059490282549250
# Apparently it does the same as netstat -tunapl but less complicated.
#
# The regexp ensures we match the first (local) port not the second (remote) port.
# If run without being root, this can list ports opened by other users, but it won't actually list the PIDs or names of those processes.
# We could add -t and -u to restrict to TCP/UDP
netstat -anp --numeric-ports | grep ":${PORT}\>.*:"
exit "$?"



# Old method using fuser; slower and requires root for other owned processes!

# Meh.  We get this message when using sudo, because UID remains unchanged.
# Meh.  Now getting this message even when logged in as root and already started jsh.  Ok changing shebang from sh to bash fixed that.
[ "$UID" = 0 ] || echo "You probably need to be root."

# For multiple ports, you can separate with ','s.
fuser -v "${PORT}/tcp"
exit "$?"
