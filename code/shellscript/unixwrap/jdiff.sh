if test ! "$COLUMNS"
then
	COLUMNS=80
	error "Please export COLUMNS."
fi

if test "$1" = "-infg"
then shift
elif xisrunning
then bigwin "jdiff -infg $@ | more" && exit
fi

echo "diff $@:"
diff -W $COLUMNS --side-by-side $@ |
# tee /tmp/b4jdiff |
## These two break rarely:
highlight -bold '^.* <$' red |
highlight -bold '^[ 	][ 	]*>\(.*\| .*\|	.*\|\)$' green | ## eh?!
## I see no way of fixing this which breaks often, even by matching ~ COLUMNS/2 chars because diff -sbs outputs TABS!
## We could demand only one '|' on the entire line (or maybe an odd number!), which would drop all false positives (many), but also a few (fewer) true positives.
highlight -bold '^.* |\(	.*\|\)$' yellow |
# highlight -bold '.*[ 	][ 	][ 	]*|\(	.*\|$\)' yellow | ## now forces 2+ tabs/spaces.  Oh dear that's not the case for wide files
more
