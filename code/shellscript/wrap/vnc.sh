## Still too high for Boris:
# vncserver -geometry 980x680
## Better for Boris:
# vncserver -geometry 800x480
## Try for Boris:
# vncserver -geometry 800x520

## Nice and big:
# I wanted -dpi 80 but Gnome (xscreensaver) lost its fonts
# vncserver -depth 16 -geometry 1024x768 -dpi 75
# vncserver -depth 16 -geometry 1024x768 -dpi 100
DESKTOP=`
	vncserver -depth 16 -geometry 800x600 -dpi 75 2>&1 |
	pipeboth |
	grep "desktop is" | afterlast ":"
`

echo "Found: >$DESKTOP<"

if xisrunning
then xvncviewer hwi:"$DESKTOP"
fi
