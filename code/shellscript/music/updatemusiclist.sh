# The extra slash on mp3s/ ensures find follow the link (if not use -follow)
find /stuff/mp3s/ -iname "*.mp3" |
grep -v /horrid/ |
grep -v /dontplay/ |
grep -v /_dontplay/ |
sed 's+\(.*\)/\(.*\)+"\2" \1/\2+' | sort -f -k 1 | sed 's+.*" ++' > $JPATH/music/list.m3u

TOMOD=$$
MODCOM="renice -15 -p $TOMOD"
export DISPLAY=
requestsudo "$MODCOM"

# consolemixer

# cat $JPATH/music/list.m3u | mpg123 -Z@-

jrep randommp3
