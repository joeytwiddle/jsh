# Seems to need slocate!  Standard locate doesn't work.
IREG=`echo "$1" | sed --file /home/joey/iregex.sed`
echo "> $IREG <"
`jwhich locate` -r $IREG
