#!/usr/local/bin/zsh

jwhich inj vim > /dev/null
if test ! "$?" = "0"; then
  echo "Oh no!  vim not present"
  exit 1
fi

FILE="$1";

# MAXVOL=$[70*40];
MAXVOL=$((120*50));
ARGS=$*; # -bg white -fg black

# Determine optimal height
LINES=`cat $FILE | countlines`
ROWS="50"
if test $LINES -lt $ROWS; then
  # ROWS=$[$LINES+2];
  ROWS=$(($LINES+2));
fi

# Determine optimal width
LONGEST=`longestline $FILE`
# LONGEST=$[$LONGEST+1]; # THIS DOESN'T WORK WITH sh ON Solaris!
LONGEST=$(($LONGEST+1));
#echo "$LONGEST"
# COLS=$[$MAXVOL/$ROWS];
COLS=$(($MAXVOL/$ROWS));
#echo "$MAXVOL/$ROWS = $COLS but $LONGEST"
if test $LONGEST -lt $COLS; then
  COLS=$LONGEST;
fi

#echo "$COLS"x"$ROWS"
if test $COLS -lt 20; then
  COLS=20
fi
if test $ROWS -lt 15; then
  ROWS=15
fi

#echo "$COLS"x"$ROWS"

TITLE=`filename "$ARGS"`"("`dirname "$ARGS"`"/)"
# TITLE="vi:$ARGS"

# FONT="-font '-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'"
# XTFONT='-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv';
XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso8859-1';
`jwhich xterm` -fg white -bg black -geometry "$COLS"x"$ROWS" -font $XTFONT -title "$TITLE" -e vim $*

# xterm -geometry 70x40 -font '-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' -title "vim:$ARGS" -e "vim $ARGS"
# gnome-terminal -geometry 70x40 --font='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' --title="vim:$ARGS" --execute="vim $ARGS"
