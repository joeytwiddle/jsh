if test ! "$COLUMNS"
then
	COLUMNS=80
	error "Please export COLUMNS."
else COLUMNS=`expr $COLUMNS - 8`
fi

if test "$1" = "-infg"
then shift
elif xisrunning
then bigwin "jdiff -infg $@ | more" && exit
fi

FILEA="$1"
FILEB="$2"

## I thought tabs were causing jdiff output formatting problems, but it wasn't them!
# FILEAx=`jgettmp "$FILEA"`
# FILEBx=`jgettmp "$FILEB"`
# cat "$FILEA" | tr '\t' ">" > $FILEAx
# cat "$FILEB" | tr '\t' ">" > $FILEBx

echo "diff $@:"
# diff -W $COLUMNS --side-by-side "$FILEAx" "$FILEBx" |
diff -W $COLUMNS --side-by-side "$FILEA" "$FILEB" |
# tee /tmp/b4jdiff |
## These two break rarely:
highlight -bold '^.* <$' red |
highlight -bold '^[ 	][ 	]*>\(.*\| .*\|	.*\|\)$' green | ## eh?!
## I see no way of fixing this which breaks often, even by matching ~ COLUMNS/2 chars because diff -sbs outputs TABS!
## We could demand only one '|' on the entire line (or maybe an odd number!), which would drop all false positives (many), but also a few (fewer) true positives.
highlight -bold '^.* |\(	.*\|\)$' yellow |
# highlight -bold '.*[ 	][ 	][ 	]*|\(	.*\|$\)' yellow | ## now forces 2+ tabs/spaces.  Oh dear that's not the case for wide files
more
