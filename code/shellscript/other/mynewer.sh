# jsh-ext-depends: find
FOUND=`find "$1" -newer "$2" -maxdepth 0`
[ "$FOUND" ]
