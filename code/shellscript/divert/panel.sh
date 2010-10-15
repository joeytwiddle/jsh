#!/bin/sh
PANEL=`jwhich panel`
if [ ! "$PANEL" ]
then PANEL=`jwhich gnome-panel`
fi
if [ ! "$PANEL" ]
then
	error "Could not find panel or gnome-panel"
	exit 1
fi
PSRES=`ps -A | grep panel`
if test ! "$PSRES" = ""; then
	echo "Found panel already running:"
	ps -A | higrep panel
	echo "Not starting new panel."
else
	cd $HOME
	# mv .gnome-last.tgz .gnome-prev.tgz
	tar cfz .gnome_panel_bak.tgz .gnome
	rotate -nozip -max 10 .gnome_panel_bak.tgz
	xterm -e "$PANEL" &
fi
