if [ "$DO" ]
then verbosely "$@"
else echo "Suggest: `cursebold`$*`cursebold` - retry with DO=1"
fi
