#!/bin/sh

NAME="$1"
if test "$NAME" = "-f"; then
  FORCE="-f";
  NAME="$2"
fi
# TOOL=`find "$JPATH/code/shellscript/" -name "$NAME"`
# TOOL=`justlinks $JPATH/tools/ | grep "^$NAME===" | after "==="`
LSLINE=`justlinks $JPATH/tools/$NAME`
#echo "Got: $LSLINE"

TOOL="$LSLINE";  # `echo "$LSLINE" | after symlnk`
# echo "Found: $TOOL"
if test "x$TOOL" = "x"; then TOOL="."; fi
# Can't put quotes around the -f "$TOOL" !
if test "x$TOOL" != "x" -a -f $TOOL; then
  echo -e -n ""
  # echo "Found tool: $TOOL"
else
  TOOL="$PWD/$NAME.sh"

  #echo "Tool not found.  Would you like me to make $TOOL ?"
  #read ans
  #if [ "$ans" = "y" -o "$ans" = "yes" ]; then

  echo "Tool not found.  Please enter $JPATH/code/shellscript/<path>/$NAME.sh"
  ( cd $JPATH/code/shellscript/ &&
    ls -d */ )
  read theirpath
  if [ ! "A$theirpath" = "A" ]; then
    TOOL="$JPATH/code/shellscript/$theirpath/$NAME.sh"
    mkdir -p `dirname "$TOOL"`
    echo "Creating new tool $TOOL"
    touch "$TOOL"
    chmod a+x "$TOOL"
    ln -sf "$TOOL" "$JPATH/tools/$NAME"
  else
    exit 1
  fi
fi
#echo ">$TOOL<"

edit $FORCE "$TOOL" # now handles below

#if xisrunning; then
#  editandwait $FORCE "$TOOL" &
#else
#  editandwait $FORCE "$TOOL"
#fi


# Neither on Unix:
# whereis $1
# which $1
# jwhere $1
jwhich $1 quietly
jwhich inj $1 quietly





#case $TERM in
#  xterm)
#    editandwait $JPATH/tools/$1 && chmod a+x $JPATH/tools/$1 &
#    ;;
#  *)
#    editandwait $JPATH/tools/$1
#    chmod a+x $JPATH/tools/$1
#    ;;
#esac
