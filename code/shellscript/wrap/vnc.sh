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
ADDRESS=`
	vncserver -depth 16 -geometry 800x600 -dpi 75 2>&1 |
	pipeboth |
	grep "desktop is " | after "desktop is "
`

# echo "Found: >$ADDRESS<"

sleep 5
if xisrunning
then
	echo "Running X vnc viewer"
	xvncviewer "$ADDRESS"
then
	echo "Running java vnc viewer"
	cd /stuff/joey/src/deb/vnc-java-3.3.3r2/
	appletviewer page.html
else
	echo "Running console vnc viewer"
	svncviewer "$ADDRESS"
fi
