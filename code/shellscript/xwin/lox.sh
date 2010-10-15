#!/bin/sh
# startx -- -bpp 24

#newback
cp /etc/X11/XF86Config-4.lowres /etc/X11/XF86Config-4
startx 2>&1 | tee $JPATH/logs/X.log
#xinit $JPATH/tools/kde.xinit
