SCRIPTNAME="$1"

NL="
"

JSHDEPS=""
EXTDEPS=""
TODO=""

for X
do TODO="$X$NL"
done

while [ "$TODO" ]
do

  # echo "`cursered;cursebold`New run:" $TODO
  JSHDEPS="$TODO$NL$JSHDEPS"
  TODOLAST="$TODO"
  TODO=""
  for SCRIPT in $TODOLAST
  do

    # JSHDEPS="$JSHDEPS$NL$SCRIPT"
    # echo "Checking $SCRIPT ..."
    # ADDJSH=`findjshdeps "$SCRIPT" 2>/dev/null | grep -v "^  " | grep -v "^$" | grep " (jsh)$" | sed 's+ (jsh)$++'`
    # ADDEXT=`findjshdeps "$SCRIPT" 2>/dev/null | grep -v "^  " | grep -v "^$" | grep -v " (jsh)$"`
    ADDJSH=`jshdepwiz getjshdeps "$SCRIPT"`
    ## TODO: This line should not be commented:!
    # ADDEXT=`jshdepwiz getextdeps "$SCRIPT"`

    echo -n "`cursecyan`$SCRIPT`cursenorm`: " >&2
    for NAME in $ADDJSH
    do
      if ! echo "$TODO$NL$JSHDEPS$NL$EXTDEPS" | grep "^$NAME$" > /dev/null
      then
          # echo "    depends: $NAME"
          TODO="$TODO$NL$NAME"
          echo -n "$NAME " >&2
      # else echo "    skipping: $NAME $WHERE"
      fi
    done
    echo >&2

    for NAME in $ADDEXT
    do
      if ! echo "$TODO$NL$JSHDEPS$NL$EXTDEPS" | grep "^$NAME$" > /dev/null
      then
          # echo "    ext-depends: $NAME"
          EXTDEPS="$EXTDEPS$NL$NAME"
      # else echo "  Already seen: $NAME $WHERE"
      fi
    done

    # echo "New dependencies from `cursecyan`$SCRIPT`cursenorm`:	" $TODO
    # echo

  done

  # echo "End run."
  # echo "<todo>$NL$TODO$NL</todo>" | tr '\n' ' '; echo

done

# echo "Results:"
# echo "<jshscripts>$NL$JSHDEPS$NL</jshscripts>" | trimempty
# echo "<extscripts>$NL$EXTDEPS$NL</extscripts>" | trimempty

echo "All dependencies:" $JSHDEPS >&2

TMPFILE=`jgettmp compilejshscript $SCRIPTNAME`

FINALSED='s+^\([ 	]*\)\. ++'
for DEP in $JSHDEPS
do
  echo "## import of $DEP from jsh"
  makeshfunction `which "$DEP"`
  echo
  if contains "$DEP" -
  then
    NEWDEP=`echo "$DEP" | tr '-' '_'`
    FINALSED="$FINALSED;s+\<$DEP\>+$NEWDEP+g"
  fi
done > $TMPFILE

(
  cat "/tmp/$SCRIPTNAME.tmp"
  echo
  echo "$SCRIPTNAME \"\$@\""
) |
sed "$FINALSED"

