# jsh-depends: highlight bigwin xisrunning error
## BUGS: Sometimes highlighting matches "><|"s which are not actually diff--side-by-side's change description tags.
## TODO: Eliminate bug #1 by escaping characters, ignoring them during highlight, and unescaping them again for output.

if [ "$1" = --help ] || [ ! "$*" ]
then
	echo
	echo "jdiff [ -infg ] [ -diffopts <opts_for_gnu_diff> ] <filea> <fileb>"
	echo
	echo "    It's just a nice human way of seeing diffs."
	echo
	echo "    It attempts to highlight all added/removed/changed lines, but sometimes gets false positives."
	echo
	exit 1
fi

if [ ! "$COLUMNS" ]
then
	COLUMNS=72
	error "Please export COLUMNS."
else
	COLUMNS=`expr $COLUMNS - 8` ## fix hack
fi
export COLUMNS

if [ "$1" = "-infg" ]
then shift
elif xisrunning
then bigwin "jdiff -infg $@ | more" && exit
fi

if [ "$1" = -diffopts ]
then
	DIFFOPTS="$2"
	shift; shift
fi

FILEA="$1"
FILEB="$2"

## I thought tabs were causing jdiff output formatting problems, but it wasn't them!
# FILEAx=`jgettmp "$FILEA"`
# FILEBx=`jgettmp "$FILEB"`
# cat "$FILEA" | tr '\t' ">" > $FILEAx
# cat "$FILEB" | tr '\t' ">" > $FILEBx

WSC="[	 ]"

echo "diff $@:"
# diff -W $COLUMNS -b --side-by-side "$FILEAx" "$FILEBx" |
diff $DIFFOPTS -W $COLUMNS -b --side-by-side "$FILEA" "$FILEB" |
# tee /tmp/b4jdiff |
## These two break rarely:
highlight -bold '^.* <$' red |
highlight -bold '^[ 	][ 	]*>\(.*\| .*\|	.*\|\)$' green | ## eh?!
## I see no way of fixing this which breaks often, even by matching ~ COLUMNS/2 chars because diff -sbs outputs TABS!
## We could demand only one '|' on the entire line (or maybe an odd number!), which would drop all false positives (many), but also a few (fewer) true positives.
## i have changed following since writing above:
## Now it colours very likely changed line in bright yellow, and maybe changed lines in dark yellow.
highlight -bold "^.*$WSC$WSC|$WSC$WSC.*$" yellow |
highlight "^.*$WSC|$WSC.*$" yellow |
  ##                \\ should we have 1 or 2 spaces here?  1 matches lots of false +ves in files, but 2 fails to match changed lines which are so long they leave no space.  :-(
# highlight -bold '.*[ 	][ 	][ 	]*|\(	.*\|$\)' yellow | ## now forces 2+ tabs/spaces.  Oh dear that's not the case for wide files
more
