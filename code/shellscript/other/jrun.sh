#!/usr/local/bin/zsh

# Derive j/ path from execution of this script

TOOLDIR=`dirname "$0"`
TOOLJDIR=`dirname "$TOOLDIR"`

# Collect all the paths we might try to find j/ in

TRYDIRS="$TOOLJDIR
$HOME/j
/home/joey/j
/home/joey/linux/j
/home/pgrad/pclark/solaris/j"

# Perform the search

DONE="false" # this is for #!/bin/sh but not working yet

echo "$TRYDIRS" | while read X; do
  # echo "Trying >$X< $DONE"
  if test "$DONE" = "false"; then
    if test -d "$X"; then
      if test -x "$X/startj"; then
        # exec $X/startj
        # source $X/startj
        . $X/startj
        $*
				RES="$?"
				export DONE="true";
        exit "$RES"
      fi
    fi
	fi
done

if test "$DONE" = "false"; then
  echo "jrun: Can't find your j installation in any of:"
  echo "$TRYDIRS"
  echo "Sorry!"
  exit 1
fi

#  if test -e "$JPATH/tools/$1"; then
#    $JPATH/tools/$*
#  else
#    $*
#  fi
