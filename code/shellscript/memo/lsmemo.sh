#!/bin/sh
. jgettmpdir -top
MEMODIR=$TOPTMP/memo

if [ "$PWD" = / ]
then REALPWD=/
else REALPWD=`realpath "$PWD"`
fi
# CKSUM=`echo "$REALPWD/$*" | md5sum`
CKSUM="*"
# NICECOM=`echo "$CKSUM..$*..$REALPWD" | tr " \n/" "__+" | sed 's+\(................................................................................\).*+\1+'`
NICECOM=`echo "$REALPWD: *.$CKSUM" | tr " /" "_+" | sed 's+\(................................................................................\).*+\1+'`
# FILE="$MEMODIR/$NICECOM.memo"
FILES="$MEMODIR/$NICECOM*.memo"

echo "`curseyellow`Commands run from this directory which have been memoed:`cursenorm`"
ls $FILES | afterfirstall ':_' | sed 's+.[^\.]*.memo$++' | tr "_+" " /"
