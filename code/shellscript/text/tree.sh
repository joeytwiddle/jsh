## Calls my Haskell version
## eg. find /var/lib/apt/lists/ | sort | tree

## Notes for generation 2:
## There is a problem that we don't know where to split until we have read all the lines below the current split.
## E.g.:
##
##     /aaa/aaa/aaa    <-- We should split here on the first '/'
##     /aaa/aaa/bbb
##     /aaa/aaa/ccc
##     /aaa/bbb/aaa    <-- But we don't know that until we reach here!
##     /aaa/bbb/bbb
##     /aaa/bbb/ccc
##     /abc/aaa/aaa    <-- Oh gosh.  If we we splitting by chars, we should have split on '/a' earlier!
##
## The original tree.hs solution read in the whole file before processing.  This is not ideal.
##
## An alternative approach, that would allow some streaming, is:
##
## - Read lines in, and use an internal data structure to split *anywhere* that there *could* be a split.  Depending on the configuration, this might be on every character.
##   E.g. ['/', 'a', 'a', 'a', '/', 'a', 'a', 'a', '/', 'a', 'a', 'a']
##   Well except we are building a tree.  But that is just to show that we split on every char!
##
## - After a split below a certain level is complete, then we can process the children above, and collapse those splits that didn't need to be splits (e.g. only had one child).
##   E.g. when we hit "/bbb/..." then we can process all the "/a..."s and then decide whether we needed to split at '/aaa/aaa/' or at '/aaa/' or at '/a'.
##
## I suspect we still won't be able to stream the output, unless we pop all the way up to ''.  Because we won't know until the end of the file/stream, whether or not we needed to split the lead character '/' and './' or not.
## But at least our tree will effectively compress it while we are reading it, so there will be less in memory than if we read it plain!

if [ "$1" = --help ]
then
cat << EOF

tree [ -java | -sh ] [ <file> ]

treesh [ -onlyat <delimeter> ] [ - ] [ <file> ]

  will group the given lines of text into a tree-shaped structure, and
  present a navigation interface (currently Vim).

  Adjacent input lines which start with the same text will be grouped together.
  For example, a list of file-paths will get grouped by directory, as in:

    find $JPATH/code/shellscript/ -type f | treesh -onlyat / -
    find /tmp | tree

  The current navigation interface (treevim) is Vim with a custom folding plugin.
  The keys -=_+ expands/contracts branches; NumPad's /* expands/contracts levels.

  treesh's - option will send the output to stdout instead of to Vim.

  tree will call the Hugs implementation by default, or treesh if it is missing.
  tree will call the java or shell implementation if -java or -sh is specified.

EOF
exit 0
fi



[ "$1" = -java ] && TREECOM="env CLASSPATH=$HOME/j/code/java java tools.tree.Tree" && shift

[ "$1" = -sh ] && TREECOM="treesh -" && shift

if [ -z "$TREECOM" ]
then
	## Use compiled Haskell treelist tool if available.
	HASKELL_TREELIST_BINARY="$JPATH/code/haskell/tools/treelist"
	if [ -x "$HASKELL_TREELIST_BINARY" ]
	then TREECOM="$HASKELL_TREELIST_BINARY" ## Compiled with ghc =)
	#elif which hugs >/dev/null && [ -f "$JPATH/code/haskell/tools/treelist.hs" ]
	#then TREECOM="runhugs $JPATH/code/haskell/tools/treelist.hs"
	else TREECOM=treesh ## fallback
	fi
	[ -n "$DEBUG" ] && debug "Using TREECOM=$TREECOM"
	## Hugs interpreter is not efficient:
	# runhugs $JPATH/code/haskell/tools/treelist.hs $TMPFILE
	# $JPATH/code/haskell/tools/treelist.hs $TMPFILE
	# highlight '\#' blue |
	# highlight '@' red
fi

[ "$1" = - ] && CAT=true && shift ## previously -cat and -novim


## The tmpfile is actually only needed by the Hugs implementation:
export TMPFILE=`jgettmp tree`
cat "$@" > $TMPFILE

$TREECOM "$TMPFILE" |

if [ -n "$CAT" ]
then
	# cat
	cat | highlight "^+ .* {" green | highlight "^- .* }" red
else
	treevim -
fi

jdeltmp $TMPFILE



################# OLD STUFF (shellscript attempt - is it worth anything or should it be chucked?)
exit
#################

filetodiff () {
	echo "$1" > /tmp/1
	echo "$2" > /tmp/2
	CHARS=`
		cmp /tmp/1 /tmp/2 |
		sed "s/.*char \([^,]*\), line 1/\1/"
	`
	# cmp /tmp/1 /tmp/2
	# echo ">>> %%% >$CHARS<" > /dev/stderr
	if test "$CHARS" = ""; then
		printf "0"
	else
		# Needed since cmp only seems to start at char 2!
		CHARS=`expr "$CHARS" - 2`
		cat /tmp/1 | sed "s/\(.\)/\1\\
/g" | head -$CHARS | tr -d "\n"
	fi
}

STACK=""
CURRENT=""
LASTLINE=""
N=0

while read LINE; do
	echo ">>> "
	echo ">>> !!! $N >$CURRENT<" > /dev/stderr
	echo ">>> >>> $LINE"
	TODROP=""
	while ! startswith "$LINE" "$CURRENT"; do
		echo ">>> *** not inside current"
		N=`expr "$N" - 1`
		CURRENT=`echo "$STACK" | tail -n 1`
		STACK=`echo "SSTACK" | chop 1`
		echo ">>> ### end"
		TODROP="$TODROP
}"
	done
	if test ! "$TODROP" = ""; then
		echo "$LASTLINE $TODROP"
	else
		echo ">>> *** inside current"
		echo ">>> ((( $LASTLINE"
		DIFF=`
			filetodiff "$LASTLINE" "$LINE" |
			sed "s^$CURRENT"
		`
		EXTRACHARS=`echo "$DIFF" | awk ' { print length($0) } '`
		echo ">>> @@@ $EXTRACHARS $DIFF"
		if test "$DIFF" = "" || test "$EXTRACHARS" -lt 2; then
			echo ">>> ### normal"
			echo "$LASTLINE"
		else
			N=`expr "$N" + 1`
			STACK="$STACK
$CURRENT"
			echo ">>> ### start $DIFF"
			echo "{ + $DIFF"
			echo "$LASTLINE"
			CURRENT="$CURRENT$DIFF"
		fi
	fi
	LASTLINE="$LINE"
done

echo "$CURRENT"
while test "$N" -gt "0"; do
	N=`expr "$N" - 1`
	echo "} # for good measure"
done
