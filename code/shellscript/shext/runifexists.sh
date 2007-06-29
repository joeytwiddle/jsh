COMMAND=`which "$1"`
shift

if [ "$COMMAND" ] && [ -x "$COMMAND" ]
then "$COMMAND" "$@"
fi

