if test "$1" = ""; then
  echo "highlight [-bold] <string> [<color>]"
  echo "  Note: the search <string> will be fed into sed, so may be in sed format."
  exit 1
fi

BOLD=
if test "$1" = "-bold"; then
  BOLD=1
  shift
fi

COLOR="$2"
if test "$COLOR" = ""; then
	# COLOR="yellow"

	# Try to work out what colour to use by counting already running highlights
	# PID=$$
	# COMS=""
	# while test ! "$PID" = "0"; do
		# PID=`getppid $PID`
		# COM=`myps -A | takecols 3 8 | grep "^$PID " | takecols 2`
		# COMS="$COM$COMS
	# "
		# # echo "$PID $COM"
	# done
	# COUNT=`echo "$COMS" | grep "^highlight$" | countlines`
	# COLI=`expr 1 + $COUNT`

	# Much quicker, but we get fairly sporadic numbers!
	# CNT="$JPATH/tmp/highlight.count"
	# echo >> "$CNT"
	# COLI=`countlines "$CNT"`

	# Nope no joy with this one - it sees all the highlights
	# GREPSTRING="highlight\.sh"
	# COLI=`myps -A | grep "$GREPSTRING" | grep -v "grep $GREPSTRING" | countlines`

	# OK this one works now that I've randomised randomorder with $$
	COLI=`seq 1 5 | tr " " "\n" | chooserandomline`

	# echo ">$COLI< hvprel nan over"

	# COLI=3
	if test "$COLI" = 1 || test "$COLI" = 4; then BOLDI=1; else BOLDI=0; fi
	# BOLDI=1
	HIGHCOL=`printf '\033[0'"$BOLDI"';3'"$COLI"'m'`

else

	HIGHCOL=`curse$COLOR`
	if test $BOLD; then
	  HIGHCOL="$HIGHCOL"`cursebold`
	fi

fi

NORMCOL=`cursegrey`

printf "$NORMCOL"
# sed "s#$1#$HIGHCOL$1$NORMCOL#g"
sed "s#\($1\)#$HIGHCOL\1$NORMCOL#g"
