cvs -q commit "$@" | grep -v "^? " &&
cvsedit
