# Um, since aliasing l='ls -l', I have been tending to type 'ld' instead of 'l -d' when looking at directories.
# This is rather dodgy if the first isn't a directory!

if test "$1" = "" || test -d "$1"; then
	ls -lartFd --color "$@"
else
echo 2
	`jwhich ld` "$@"
fi
