PSRES=`ps -A | grep panel`
if test ! "$PSRES" = ""; then
	echo "Found panel already running:"
	ps -A | higrep panel
	echo "Not starting new panel."
else
	cd $HOME
	mv .gnome-last.tgz .gnome-prev.tgz
	tar cfz .gnome-last.tgz .gnome
	xterm -e `jwhich panel`
fi
