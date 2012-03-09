#!/bin/sh
# jsh-depends-ignore: startj-hwi
# jsh-ext-depends: sed
# jsh-ext-depends-ignore: dir find file

## When compiljsh puts a wrapper sh in a function, it may call jwhich on itself.
## To avoid inf loop jwhich should return full path or nothing, never just the
## name of the script.

## bash has 'type'.  How is this different from 'where' or 'which'?

if [ "$1" = "" ] || [ "$1" = --help ]
then
    echo "jwhich <command> [ quietly ]"
    echo "  will find the executable file in your \$PATH minus anything that looks like jsh's JPATH"
    echo "  now deprecated in favour of: unj which <command>"
    echo "jwhich inj <command> [ quietly ]"
    echo "  will look in cyour current \$JPATH for <file>"
    echo "  quietly means it just checks and returns 1/0, but does not print anything."
    exit 1
fi

## This script won't stop an infloop if you symlink a jsh script into a different PATH folder, e.g. ~/bin !

## Why not grep -v?  I guess we'd need to unj it wouldn't we!

## Instead of ungrepping, we could do a test for $PATHDIR/jsh to be super-sure.
## This would be slow but would remove the occasional possible inf-loop problems.

fakeungrep () {
   sed "s|.*$*.*||"
}

if test "$1" = "inj"
then
    # PATHS=`echo "$PATH" | tr ":" "\n"`
    # INJ=true
    # shift

	## New fast implementation
	[ -x "$JPATH/$2" ] && echo "$JPATH/$2" || false
	exit
else
    # Remove all references to JLib from the path
    PATHS=`echo "$PATH" | tr ":" "\n" |
			if [ "$JPATH" ] ## just in case we arent in jsh!
			then fakeungrep "$JPATH"
			else cat
			fi
		`
fi
FILE="$1"
QUIETLY="$2"

# Note the quotes around $PATHS here are important, otherwise unix converts into one line again!
# This is no good cos it spawns a new process, and the exit doesn't work.
# echo "$PATHS" | while read dir; do
# This seems to work better, although there may be problems with spaces in the PATH
for dir in $PATHS
do
  if test -f "$dir/$FILE"
  then
      ## Skip this one if it looks like _another_ instance of jsh on the path.
      ## (Except if doing inj.)  Needed this because simple_init was recursively calling screen and filling mem evil-ly :/ :/
      if [ ! "$INJ" ] && ( [ -f "$dir/../startj" ] || [ -f "$dir/../startj-hwi" ] )
      then continue
      fi
      test ! "$QUIETLY" && echo $dir/$FILE
      exit 0      # Found!  :)
  fi
done

## For debug: returns this command as "found" file (useful cos it's non-empty so it reaches further!)
# echo "jwhich_error_could_not_find_$FILE"

exit 1          # Not found  :(
