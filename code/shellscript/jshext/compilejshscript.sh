## This is rubbish.
## It might be usable if it could also use and add developer-augmented dependency info embedded in script.

NL="
"

LISTJSH=""
LISTEXT=""

TODO=""
for X
do TODO="$X
"
done

while [ ! "$TODO" = "" ]
do

  LISTJSH="$LISTJSH$NL$TODO"
  TODOLAST="$TODO"
  TODO=""
  for SCRIPT in $TODOLAST
  do

    # LISTJSH="$LISTJSH$NL$SCRIPT"
    echo "Finding dependencies for $SCRIPT ..."
    ADDJSH=`findjshdeps "$SCRIPT" 2>/dev/null | grep -v "^  " | grep -v "^$" | grep " (jsh)$" | sed 's+ (jsh)$++'`
    ADDEXT=`findjshdeps "$SCRIPT" 2>/dev/null | grep -v "^  " | grep -v "^$" | grep -v " (jsh)$"`
    ADDJSH=`jshdepwiz getjshdeps "$SCRIPT"`
    ADDEXT=`jshdepwiz getextdeps "$SCRIPT"`

    for NAME in $ADDJSH
    do
      if ! echo "$TODO$NL$LISTJSH$NL$LISTEXT" | grep "^$NAME$" > /dev/null
      then
          echo "  Adding todo: $NAME"
          TODO="$TODO$NL$NAME"
      # else echo "  Already seen: $NAME $WHERE"
      fi
    done

    for NAME in $ADDEXT
    do
      if ! echo "$TODO$NL$LISTJSH$NL$LISTEXT" | grep "^$NAME$" > /dev/null
      then
          echo "  Adding ext: $NAME"
          LISTEXT="$LISTEXT$NL$NAME"
      # else echo "  Already seen: $NAME $WHERE"
      fi
    done

    echo "  part run: <todo.>$NL$TODO$NL</todo.>" | tr '\n' ' '; echo

  done

  echo "End run."
  echo "<todo>$NL$TODO$NL</todo>" | tr '\n' ' '; echo

done

echo "Results:"
echo "<jshscripts>$NL$LISTJSH$NL</jshscripts>"
echo "<extscripts>$NL$LISTEXT$NL</extscripts>"

