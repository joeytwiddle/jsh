# Usage: . includepath <root-prefix>

NEWROOT="$1"

PATH="$NEWROOT/bin:$PATH"
MANPATH="$NEWROOT/man:$MANPATH"
LD_LIBRARY_PATH="$NEWROOT/lib:$LD_LIBRARY_PATH"

export PATH;
export MANPATH;
export LD_LIBRARY_PATH;
