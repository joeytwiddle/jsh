TF=`jgettmp $$`
NUMLINES=`tee "$TF" | countlines`
KEEPLINES=`expr $NUMLINES - $1`
cat "$TF" | head -n "$KEEPLINES"
