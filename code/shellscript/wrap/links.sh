#!/bin/sh
if test $1; then
`jwhich links` "$@"
else
`jwhich links` $JPATH/org/jumpgate.html
fi
