#!/bin/sh
SEARCHRE=`toregexp "$1"`
REPLACERE="$2"
shift ; shift

sed "s$SEARCHRE$REPLACEREg" "$@"

