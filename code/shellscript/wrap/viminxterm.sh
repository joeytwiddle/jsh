#!/bin/sh
# #!/usr/local/bin/zsh

jwhich inj vim > /dev/null
if test ! "$?" = "0"; then
  echo "Oh no!  vim not present"
  exit 1
fi

FILE="$1";

# MAXVOL=$[70*40];
MAXVOL=$((80*50));
ARGS=$*; # -bg white -fg black

if test -f "$FILE"; then

  # Determine optimal height
  LINES=`cat $FILE | countlines`
  # echo "lines=$LINES"
  ROWS="50"
  if test $LINES -lt $ROWS; then
    # ROWS=$[$LINES+2];
    # ROWS=$(($LINES+2));
echo "A"
    # ROWS=$(($(($LINES+2))*1.1));
    ROWS=`eval $LINES+2`;
echo "B $ROWS"
  fi
  
  # Determine optimal width
  LONGEST=`longestline $FILE`
  # echo "cols=$LONGEST"
  # LONGEST=$[$LONGEST+1]; # THIS DOESN'T WORK WITH sh ON Solaris!
  # LONGEST=$(($LONGEST+2));
  LONGEST=$(($(($LONGEST+2))*1.1));
  #echo "$LONGEST"
  
  # Determine optimal distribution
  # COLS=$[$MAXVOL/$ROWS];
  COLS=$(($MAXVOL/$ROWS));
  #echo "$MAXVOL/$ROWS = $COLS but $LONGEST"
  if test $LONGEST -lt $COLS; then
    COLS=$LONGEST;
  fi

  # echo "$COLS"x"$ROWS"
  if test $COLS -lt 20; then
    COLS=20
  fi
  if test $ROWS -lt 5; then
    ROWS=5
  fi

else

  COLS=40
  ROWS=20
  
fi

# echo "$COLS"x"$ROWS"

INTGEOM=`echo "$COLS"x"$ROWS" | sed 's|\..*x|x| ; s|\..*$||'`
  
# TITLE="vi:$ARGS"
# TITLE=`filename "$ARGS"`"("`dirname "$ARGS"`"/)" # This seems to be what Vim actually forces on the xterm.
TITLE=`absolutepath "$ARGS"`" [vim]"

# FONT="-font '-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'"
# XTFONT='-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv';
# XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso8859-1';
XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1';
`jwhich xterm` -fg white -bg black -geometry $INTGEOM -font $XTFONT -title "$TITLE" -e vim $*

# xterm -geometry 70x40 -font '-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' -title "vim:$ARGS" -e "vim $ARGS"
# gnome-terminal -geometry 70x40 --font='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' --title="vim:$ARGS" --execute="vim $ARGS"
