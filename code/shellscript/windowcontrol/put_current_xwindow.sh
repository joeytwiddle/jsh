#!/bin/sh
# jsh-ext-depends: xdotool xwininfo sed cut xdpyinfo
# jsh-depends-ignore: top

## NOTE: It is preferable to use the ported version put_current_xwindow.bash
## because it is faster.
## It is sometimes slow for bash too - perhaps when the scripts file is not
## cached.  TODO: use importshfn to preload it into the shell.  zsh at least
## doesn't seem to mind that it contains inner functions.

## Moves your current window to corner/edge/center of screen.
## Provide one of these as the argument:
## nw,top,ne,left,center,right,sw,bottom,se,center_x,center_y

## BUG: It doesn't move the mouse pointer; in Fluxbox this might mean that your
## focus will switch to the window now under the pointer.

## Config:
## If you want a gap between the edge of the screen, set the padding
[ -z "$PUT_XWINDOW_PADDING" ] && PUT_XWINDOW_PADDING=0
## If your window manager draws a border around your windows, you can specify that
[ -z "$WINDOW_BORDER_WIDTH" ] && WINDOW_BORDER_WIDTH=0

putWhere="$1"

winid=`xdotool getwindowfocus`

[ -n "$winid" ] || . errorexit "xdotool failed to find current window."

# geometry=`xwininfo -id "$winid" | grep geometry | sed 's+.* ++'`
# echo "$geometry" | extractregex "[0-9][0-9]*" |
# (
	# read width
	# read height
	# read left
	# read top
	# # ...
# )

## The -geometry 131x37-6-7 sometimes has hinting,
## so we get the x/y/width/height a different way:
xwininfo=`xwininfo -id "$winid"`
extract_window_property () {
	printf "%s" "$xwininfo" | grep "^  $1: " | sed 's+.*: *++'
}
width=`extract_window_property "Width"`
height=`extract_window_property "Height"`
left=`extract_window_property "Absolute upper-left X"`
top=`extract_window_property "Absolute upper-left Y"`
xoffset=`extract_window_property "Relative upper-left X"`
yoffset=`extract_window_property "Relative upper-left Y"`

[ "$winid" ] || . errorexit "xdotool failed to get window size."

# width=`echo "$geometry" | sed 's/\([0-9]*\)x\([0-9]*\)+.*/\1/'`

oldwidth="$width" ; oldheight="$height"
[ "$width" -lt 80 ] && width=`expr "$width" '*' 8` && height=`expr "$height" '*' 8`

# scrwidth="`getxwindimensions | cut -d x -f 1`"
# scrheight="`getxwindimensions | cut -d x -f 2`"
xwindimensions=`xdpyinfo | grep dimensions: | sed 's+.*dimensions:[ ]*++ ; s+ .*++'`
scrwidth="`echo "$xwindimensions" | cut -d x -f 1`"
scrheight="`echo "$xwindimensions" | cut -d x -f 2`"

## "Unchanged" positions:
left=`expr "$left" - "$xoffset"`
top=`expr "$top" - "$yoffset"`

top=`expr "$top" - "$WINDOW_BORDER_WIDTH"`
left=`expr "$left" - "$WINDOW_BORDER_WIDTH"`

push_left () {
	left=$PUT_XWINDOW_PADDING
}
push_right () {
	left=`expr "$scrwidth" - "$width" - "$xoffset" - $WINDOW_BORDER_WIDTH - $WINDOW_BORDER_WIDTH - $PUT_XWINDOW_PADDING`
}
push_top () {
	top=$PUT_XWINDOW_PADDING
}
push_bottom () {
	top=`expr "$scrheight" - "$height" - "$yoffset" - $WINDOW_BORDER_WIDTH - "(" $WINDOW_BORDER_WIDTH "*" 3 ")" - $PUT_XWINDOW_PADDING - 4`
	## For some reason we need an extra -7 here
	## Perhaps it has something to do wth window manager bevels?
}
push_centerx () {
	left=`expr "$scrwidth" / 2 - "$width" / 2 - "$xoffset"`
}
push_centery () {
	top=`expr "$scrheight" / 2 - "$height" / 2 - "$yoffset"`
}

case "$putWhere" in
	nw)
		push_left ; push_top
	;;
	top)
		push_top
		push_centerx
	;;
	top_edge)
		push_top
	;;
	ne)
		push_top
		push_right
	;;
	left)
		push_left
		push_centery
	;;
	left_edge)
		push_left
	;;
	center_x)
		push_centerx
	;;
	center_y)
		push_centery
	;;
	center)
		push_centerx
		push_centery
	;;
	right)
		push_right
		push_centery
	;;
	right_edge)
		push_right
	;;
	sw)
		push_left ; push_bottom
	;;
	bottom)
		push_bottom
		push_centerx
	;;
	bottom_edge)
		push_bottom
	;;
	se)
		push_right ; push_bottom
	;;
	*)
		echo "put_current_xwindow: do not recognise position \"$putWhere\"" >&2
		exit 3
	;;
esac

# wmctrl -r :ACTIVE: -e "1,$left,$top,$width,$height"
xdotool windowmove "$winid" "$left" "$top"

# ...

