cvs -q commit "$@" # | grep -v "^? "   ## causes: "Vim: Warning: Output is not to a terminal"
cvsedit "$@"
