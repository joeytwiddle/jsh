# Seems to need slocate!  Standard locate doesn't work.
IREG=`echo "$*" | sed --file /home/joey/iregex.sed`
echo "> $IREG <"
locate -r $IREG
