# cd /
# mount /mnt/cdrom
# cd /mnt/cdrom

# if [ "x$@" = "x" ]; then
  # echo "# On CD" > $JPATH/music/list.m3u
    # find /mnt/cdrom -name "*.mp3" > $JPATH/music/list.m3u
    # find /mnt/cdrom -name "*.MP3" >> $JPATH/music/list.m3u
    # find /mnt/cdrom -name "*.cda" >> $JPATH/music/list.m3u
    # find /mnt/cdrom -name "*.CDA" >> $JPATH/music/list.m3u
  # echo "# In tracks" >> $JPATH/music/list.m3u
    # find "$JPATH/tracks" -name "*.mp3" -follow >> $JPATH/music/list.m3u
    # find "$JPATH/tracks" -name "*.MP3" -follow >> $JPATH/music/list.m3u
  # echo "# From locate" >> $JPATH/music/list.m3u
    # locateend ".mp3" | ungrep "$JPATH/music/" | ungrep "$JPATH/tracks/" >> $JPATH/music/list.m3u
# fi

# cd $JPATH/music
# rm $JPATH/music/*.mp3
# forall in list -stealth do "ln -sf \"%w\" \"%n%s.mp3\""
# forall in list -stealth do "ln -sf \"%w\" \"%s.mp3\""
# rm list

# cd /stuff/mp3s
# The extra slash on mp3s/ ensures find follow the link (if not use -follow)
find /stuff/mp3s/ -iname "*.mp3" | grep -v /horrid > $JPATH/music/list.m3u

# echo "PID= $$"
# requestsudo "source $JPATH/startj
# myrenice -15 '-E (esd|mpg123|xmms|freeamp|$$)'"
(
	sleep 3s
	TOMOD=`ps -A | grep -E "(esd|mpg123|xmms|freeamp)" | takecols 1`
	requestsudo "$JPATH/tools/jrun renice -15 -p "`echo $TOMOD`
) &

# consolemixer

# cat $JPATH/music/list.m3u | mpg123 -Z@-

jrep randommp3

# nicexmms $JPATH/music/list.m3u > $JPATH/tmp/xmms-output.txt &

# if [ ! "A$@" = "A" ]; then
#   xmms $@
# fi

