BADEXTS="bbl aux log blg" # dvi

# find
COM="find ."
FIRST=true
for X in $BADEXTS; do
	if test $FIRST; then FIRST=; else
		COM="$COM -or"
	fi
	COM="$COM -name *.$X"
done

$COM
