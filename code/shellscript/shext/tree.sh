## Calls my Haskell version
## eg. find /var/lib/apt/lists/ | sort | tree

if test "$1" = "-java"
then export TREEJAVA=true; shift
fi

TREESH=
if [ "$1" = "-sh" ]
then export TREESH=true; shift
fi

if test "$1" = "-cat" || test "$1" = "-novim"
then export CAT=true; shift
fi

export TMPFILE=`jgettmp tree`
cat "$@" > $TMPFILE

if [ $TREESH ]
then

	cat $TMPFILE | treesh

else

	if test "$TREEJAVA"
	then

		java tools.tree.Tree $TMPFILE

	else

		## Hugs interpreter is not efficient:
		# runhugs $JPATH/code/haskell/tools/treelist.hs $TMPFILE
		# $JPATH/code/haskell/tools/treelist.hs $TMPFILE
		## Compiled with ghc =)
		$JPATH/code/haskell/tools/treelist $TMPFILE |
		cat
		# highlight '\#' blue |
		# highlight '@' red

	fi |

	if test "$CAT"
	then cat
	else treevim
	fi

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
		CURRENT=`echo "$STACK" | tail -1`
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
