# BORDER="BW"
# WINDOWBAR="bw"
# WINDOWHIGHLIGHT="gk"

chooserandomarg () {
	for X
	do echo "$X"
	done | chooserandomline
}

BORDER=`chooserandomarg RW GW BW CK MW YK`
WINDOWBAR=`chooserandomarg rw gk bw ck mw yk`
WINDOWHIGHLIGHT=`chooserandomarg rW gK bW CK MW YK`

# SCREEN_CAPTION="%{$BORDER} [%{BC}%H%{$BORDER}:%{BC}$SCREENNAME%{$BORDER}] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"

screen -X caption always "$SCREEN_CAPTION"
