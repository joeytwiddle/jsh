## Renice this sh to give child mpg123 priority
TOMOD=$$
MODCOM="renice -15 -p $TOMOD"
export DISPLAY=
requestsudo "$MODCOM"

## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
find /stuff/mp3s/ -iname "*.mp3" |
grep -v /horrid/ |
grep -v /dontplay/ |
grep -v /_dontplay/ |
## Sort them by filename (rather than path)
sortpathsbyfilename |
cat > $JPATH/music/list.m3u

# consolemixer

# cat $JPATH/music/list.m3u | mpg123 -Z@-

jrep randommp3
