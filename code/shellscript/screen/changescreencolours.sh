if [ "$STY" ]
then

	# BORDER="BW"
	# WINDOWBAR="bw"
	# WINDOWHIGHLIGHT="gk"

	chooserandomarg () {
		for X
		do echo "$X"
		done | chooserandomline
	}

	# BORDER=`chooserandomarg RW GW BW CK MW YK`
	# WINDOWBAR=bw
	# WINDOWHIGHLIGHT=`chooserandomarg rW gK CK MW YK`

	# WINDOWBAR=`chooserandomarg rk gk bk ck mk yk`
	# WINDOWHIGHLIGHT=`chooserandomarg RW GK BW CK MW yW`
	# BORDER=$WINDOWHIGHLIGHT

	# WINDOWBAR=`chooserandomarg rk bk mk yk`
	# WINDOWHIGHLIGHT=`chooserandomarg RW BW MW`
	# BORDER=$WINDOWHIGHLIGHT

	WINDOWHIGHLIGHT=`chooserandomarg RW GK MW CK yK`
	BORDER=$WINDOWHIGHLIGHT
	# WINDOWBAR=bk
	WINDOWBAR=bw

	SCREENBUILDYEAR=`screen --version | afterlast - | sed 's+\([[:digit:]]*\).*+\1+' | sed 's+^0++'` # 2100 incompliant
	# echo "SCREENBUILDYEAR = >$SCREENBUILDYEAR<"
	if [ "$SCREENBUILDYEAR" -lt 3 ]
	# if [ x ]
	then
		# WINLIST="%{$WINDOWBAR} %{$WINDOWHIGHLIGHT} %n %t %{kw} %{$WINDOWBAR} %W "
		# WINLIST="%{$WINDOWBAR} %{$WINDOWHIGHLIGHT} %n %{$WINDOWBAR} %w "
		## todo
		## what's todo?!
		## Wxtra bg colours:
		WINDOWBAR=`chooserandomarg rw bw kw`
		RIGHTJUST=""
		DATEBIT="%d/%M %c"
		SCREEN_CAPTION="%{$BORDER}$SHORTHOST:$SCREENNAME (%{$WINDOWBAR} %n %{$WINDOWHIGHLIGHT}) (%{$WINDOWBAR} %w $RIGHTJUST%{$WINDOWHIGHLIGHT}) $DATEBIT"
	else
		## Looks like tabs:
		# WINLIST="%{$WINDOWBAR} %-w%{kB}\\ %{kw}%n %t %{kB}/%{$WINDOWBAR}%+w "
		WINLIST="%{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %n %t %{kw} %{$WINDOWBAR}%+w "
		RIGHTJUST="%="
		DATEBIT="%d/%M"
		SCREEN_CAPTION="%{$BORDER}$SHORTHOST:$SCREENNAME ($WINLIST$RIGHTJUST%{$BORDER}) $DATEBIT"
	fi
	# SCREEN_CAPTION="%{$BORDER} [%{BC}%H%{$BORDER}:%{BC}$SCREENNAME%{$BORDER}] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
	# SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
	# SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
	# SCREEN_CAPTION="%{$BORDER}%H:$SCREENNAME(%{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER})%d/%M"
	# SCREEN_CAPTION="%{$BORDER}$SHORTHOST:$SCREENNAME%{$WINDOWHIGHLIGHT}(%{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w $RIGHTJUST%{$WINDOWHIGHLIGHT})%{$BORDER}%d/%M"
	# SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] $WINLIST $RIGHTJUST%{$BORDER} %M %d %c"
	# SCREEN_CAPTION="%{$BORDER}$SHORTHOST:$SCREENNAME%{$WINDOWHIGHLIGHT}($WINLIST $RIGHTJUST%{$WINDOWHIGHLIGHT})%{$BORDER}%d/%M"
	# SCREEN_CAPTION="%{$BORDER} [$SHORTHOST:$SCREENNAME] $WINLIST $RIGHTJUST%{$BORDER} %M %d %c"

	screen -X caption always "$SCREEN_CAPTION"

else

	echo "No STY found."
	exit 1

fi
