# jsh-ext-depends: find
# FOUND=`find "$1" -newer "$2" -maxdepth 0`
# [ "$FOUND" ]
## Changed to make behaviour same as the newer binary:
## returns true if files are the same age
FOUND=`find "$2" -newer "$1" -maxdepth 0`
[ ! "$FOUND" ]
