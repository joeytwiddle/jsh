COM="$*";
NICECOM=`echo "$PWD: $COM" | tr " /" "_-"`
FILE="$JPATH/data/memo/$NICECOM.memo"

if test -f "$FILE"; then
  cat "$FILE"
  exit 0
else
  rememo $*
fi

# found=false;
# for file in $JPATH/memo/*; do
#   memoof=`head -n 1 $file`
#   echo $memoof
#   if [ " $memoof" = " $@" ] ; then
# #    echo "Found in $file"
#     more $file
# #    found=true;
#   else
#     echo "Not $memoof"
#   fi;
# done

#if [ "$found" = "false" ] ; then
#  $@ > "$JPATH/memo/$@"
#  more "$JPATH/memo/$@"
#fi
