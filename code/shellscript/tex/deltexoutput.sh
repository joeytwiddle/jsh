BADEXTS="bbl aux log blg" # dvi

# find
GREPFOR="\.("
FIRST=true
for X in $BADEXTS; do
	if test $FIRST; then FIRST=; else
		GREPFOR="$GREPFOR|"
	fi
	GREPFOR="$GREPFOR$X"
done
GREPFOR="$GREPFOR)\$"

find . -type f | egrep "$GREPFOR"
