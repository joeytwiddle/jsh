cd $JPATH/data
cp jsync.conf.default jsync.conf
sreplace jsync.conf \@maxx \@"$HOST"
sreplace jsync.conf \@tao \@"$HOST"
if test "x$*" = "x"; then
  exit 0 # REP="hwi.dyn.dhs.org"
else
  REP="$*"
fi
sreplace jsync.conf hwi.dyn.dhs.org $REP
echo "$REP" >> $JPATH/logs/hwiwasat.txt
