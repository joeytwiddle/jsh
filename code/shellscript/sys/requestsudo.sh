(
  echo 'echo "Enter root passwd to perform:"'
  echo 'echo "'"$@"'"'
  echo 'su root -c $JPATH/tmp/sudo2.tmp'
  echo 'sleep 2'
) > $JPATH/tmp/sudo.tmp &&
echo "$@" > $JPATH/tmp/sudo2.tmp &&
chmod u+x $JPATH/tmp/sudo.tmp $JPATH/tmp/sudo2.tmp &&
if xisrunning; then
	newwin $JPATH/tmp/sudo.tmp
else
	$JPATH/tmp/sudo.tmp
fi
# 'rm' $JPATH/tmp/sudo.tmp
