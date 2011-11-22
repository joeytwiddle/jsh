## Raises all minimized windows
wmctrl -l -p -G -x |
while read ID DESKTOP PID X Y WIN_WIDTH WIN_HEIGHT WM_CLASS TITLE
do wmctrl -i -a "$ID"
   # wmctrl -i -r "$ID" -b remove,hidden
   # wmctrl -i -r "$ID" -b remove,shade
done
