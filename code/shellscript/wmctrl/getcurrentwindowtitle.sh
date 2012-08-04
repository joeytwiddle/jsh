winid=`xdotool getwindowfocus`
xwininfo -id "$winid" | grep "^xwininfo: " | sed 's+^[^"]*"++ ; s+"$++'
