# jsh-depends: playmp3andwait takecols chooserandomline filename
# jsh-depends-ignore: music del
TRACK=`cat $JPATH/music/list.m3u | chooserandomline`
# filename "$TRACK"
SIZE=`du -sh "$TRACK" | takecols 1`
echo "$SIZE: "`filename "$TRACK"`" ("`dirname "$TRACK"`")"
MP3INFO=`mp3info "$TRACK"`
echo "$MP3INFO"
# mp3info "$TRACK"
echo "del "'"'"$TRACK"'"'
/usr/bin/time -f "%e seconds ( Time: %E CPU: %P Mem: %Mk )" playmp3andwait "$TRACK"
echo
echo "--------------------------------------"
echo
