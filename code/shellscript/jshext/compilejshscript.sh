# jsh-depends-ignore: jsh
# jsh-depends: cursecyan curseyellow cursenorm makeshfunction contains jdeltmp jgettmp
## Notes on cleanup:
##   If a script sources another using . <script>, then this should be at the start of a line, not hidden in a pipe.
##   If a script exits explicily with "exit", then this should be at the start of a line, not hidden in a pipe.



## Problem: unj and jwhich don't work for functions (or do they!), so cksum might act recursively!



## TODO: In non-interactive mode, consider including jsh-depends-tocheck too, since they may well be needed, and it won't hurt (too much) if they aren't.



## For jshdepwiz:
# export DEPWIZ_NON_INTERACTIVE=true
# export DEPWIZ_VIGILANT=true
# export DEPWIZ_LAZY=true


if [ "$1" = -vigilant ]
then export DEPWIZ_VIGILANT=true; shift
fi


MAINSCRIPT="$1"

NL="
"


### Find dependencies:

echo "`curseyellow`Finding dependencies...`cursenorm`" >&2

JSHDEPS=""
EXTDEPS=""
TODO=""

for X
do TODO="$X$NL"
done

while [ "$TODO" ]
do

  # echo "`cursered;cursebold`New run:" $TODO
  ## Add todo scripts to the dependency list:
  JSHDEPS="$TODO$NL$JSHDEPS"

  ## Loop through todo scripts:
  TODOLAST="$TODO"
  TODO=""
  for SCRIPT in $TODOLAST
  do

    ## Find dependencies of script:
    # ADDJSH=`memo -d $JPATH/code/shellscript jshdepwiz getjshdeps "$SCRIPT"`
    # ADDEXT=`memo -d $JPATH/code/shellscript jshdepwiz getextdeps "$SCRIPT"`
    # REALSCRIPT=`realpath \`which "$SCRIPT"\``
    # ADDJSH=`memo -f "$REALSCRIPT" jshdepwiz getjshdeps "$SCRIPT"`
    # ADDEXT=`memo -f "$REALSCRIPT" jshdepwiz getextdeps "$SCRIPT"`
    ## Fastest but misses changes:
    # export DEPWIZ_VIGILANT=
    ADDJSH=`jshdepwiz getjshdeps "$SCRIPT"`
    ADDEXT=`jshdepwiz getextdeps "$SCRIPT"`

    ## Add depdencies to todo list, if not already there:
    if [ "$ADDJSH" ]
    then
      echo -n "`cursecyan`$SCRIPT`cursenorm`: " >&2
      for NAME in $ADDJSH
      do
        if ! echo "$TODO$NL$JSHDEPS$NL$EXTDEPS" | grep "^$NAME$" > /dev/null
        then
          TODO="$TODO$NL$NAME"
          echo -n "$NAME " >&2
        else
          echo -n "[$NAME] " >&2
        fi
      done
      echo >&2
    fi

    ## Add external depdencies to big ext list, if not already there:
    if [ "$ADDEXT" ]
    then
      echo -n "`cursecyan`$SCRIPT ext`cursenorm`: " >&2
      for NAME in $ADDEXT
      do
        if ! echo "$TODO$NL$JSHDEPS$NL$EXTDEPS" | grep "^$NAME$" > /dev/null
        then
          EXTDEPS="$EXTDEPS$NL$NAME"
          echo -n "$NAME " >&2
        else
          echo -n "[$NAME] " >&2
        fi
      done
      echo >&2
    fi

    # echo "New dependencies from `cursecyan`$SCRIPT`cursenorm`:	" $TODO >&2
    # echo

  done

  # echo "End run." >&2
  # echo "Still todo:" $TODO >&2

done

echo >&2
echo "`curseyellow`All jsh dependencies:`cursenorm`" $JSHDEPS >&2
echo "`curseyellow`All external dependencies:`cursenorm`" $EXTDEPS >&2



### Compile script by converting each dependent script into a function:

echo >&2
echo "`curseyellow`Compiling script...`cursenorm`" >&2

TMPFILE=`jgettmp compilejshscript "$MAINSCRIPT"`

## Cleanup: We cannot .|source functions, but I think they work the same when called directly anyway:
FINALSED="s+^\([ 	]*\)\. +\1+"
## Cleanup: All 'exit's must become 'return's:
FINALSED="$FINALSED;s+^\([ 	]*\)exit +\1return +"

echo -n "Importing: " >&2
for DEP in $JSHDEPS
do
  echo -n "`cursecyan`$DEP`cursenorm` " >&2
  # echo "### START IMPORT: $DEP"
  echo "### IMPORT: $DEP"
  makeshfunction `which "$DEP"`
  # echo "### END IMPORT: $DEP"
  echo
  ## Cleanup: function names may not contain '-', so rename with '_'s instead:
  if contains "$DEP" -
  then
    NEWDEP=`echo "$DEP" | tr '\-' '_'`
    FINALSED="$FINALSED;s+\<$DEP\>+$NEWDEP+g"
  fi
done > $TMPFILE
## Note: original | cat > $TMPFILE left problems export FINALSED back out.
echo >&2

echo >&2

export TMPFILE MAINSCRIPT
## Perform cleanup, and add main call to main script's function:
(
	echo "## $MAINSCRIPT [compiled on `date +'%Y/%m/%d-%H:%M'` by $USER@`hostname -f`]"
	echo "## Copyright 2003 Free Software Foundation, released under GNU Public Licence"
	echo "## This is silly - what does GPL mean for non-binarised software?!"
	echo "## Homepage: http://hwi.ath.cx/twiki/bin/view/Neuralyte/ProjectJsh"
	echo
  cat $TMPFILE
	echo "### MAIN CALL:"
  echo "$MAINSCRIPT \"\$@\""
) |
sed "$FINALSED"

jdeltmp $TMPFILE
