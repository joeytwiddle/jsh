# Usage: . includepath <root-prefix>

if test "$1" = -after
then
	NEWROOT="$2"
	PATH="$PATH:$NEWROOT/bin:$NEWROOT/usr/bin"
	MANPATH="$MANPATH:$NEWROOT/man"
	LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NEWROOT/lib:$NEWROOT/usr/lib"
else
	NEWROOT="$1"
	PATH="$NEWROOT/bin:$NEWROOT/usr/bin:$PATH"
	MANPATH="$NEWROOT/man:$MANPATH"
	LD_LIBRARY_PATH="$NEWROOT/lib:$NEWROOT/usr/lib:$LD_LIBRARY_PATH"
fi

export PATH;
export MANPATH;
export LD_LIBRARY_PATH;
