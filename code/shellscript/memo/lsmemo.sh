. jgettmpdir -top
MEMODIR=$TOPTMP/memo

REALPWD=`realpath "$PWD"`
CKSUM="*"
NICECOM=`echo "$REALPWD: *.$CKSUM" | tr " /" "_+" | sed 's+\(................................................................................\).*+\1+'`
# echo "$NICECOM"
FILES="$MEMODIR/$NICECOM*.memo"

echo "`curseyellow`Commands run from this directory which have been memoed:`cursenorm`"
ls $FILES | afterfirstall ':_' | sed 's+.[^\.]*.memo$++' | tr "_+" " /"
