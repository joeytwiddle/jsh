
propdiff () {
	# TOTALA=`countlines "$1"`
	# TOTALB=`countlines "$2"`
	# MISSINGA=`jfcsh "$1" "$2" | countlines`
	# MISSINGB=`jfcsh "$2" "$1" | countlines`
	TOTALA=`escapenewlines -x "$1" | countlines`
	TOTALB=`escapenewlines -x "$2" | countlines`
	MISSINGA=`worddiff "$1" "$2" | grep "^<" | countlines`
	MISSINGB=`worddiff "$2" "$1" | grep "^<" | countlines`
	PERCENTMISSING=` expr '(' $MISSINGA + $MISSINGB ')' '*' 100 / '(' $TOTALA + $TOTALB ')' `
	for X in `seq 1 $PERCENTMISSING`
	do printf "."
	done
}

propdiff "$1" "$2"
