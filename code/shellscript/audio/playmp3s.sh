WHERE="$@"
ENQUEUE="" # "-e"
if [ "$1" = "fresh" ]; then
  WHERE="$2"
  ENQUEUE=""
fi
if [ "$WHERE" = "" ]; then
  WHERE="$PWD/" # This '/' is vital for find to work if $PWD is a link!
else
  WHERE="$PWD/$WHERE"
fi
find "$WHERE" -name "*.mp3" > $JPATH/music/group.m3u
COM="xmms $ENQUEUE $JPATH/music/group.m3u"
echo "$COM"
$COM