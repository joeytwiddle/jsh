#!/bin/sh
TMPA=`jgettmp splicewith`
TMPB=`jgettmp splicewith`

ORDER="$TMPA $TMPB"
if test "$1" = "-after"; then
	shift
	ORDER="$TMPB $TMPA"
fi

cat > $TMPA

"$@" > $TMPB

paste -d "" $ORDER

jdeltmp $TMPA $TMPB
