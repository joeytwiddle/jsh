# jsh-depends: playmp3andwait takecols chooserandomline filename
# jsh-depends-ignore: music del
TRACK=`cat $JPATH/music/list.m3u | chooserandomline`
# filename "$TRACK"
SIZE=`du -sh "$TRACK" | takecols 1`
# echo "$SIZE: "`filename "$TRACK"`" ("`dirname "$TRACK"`")"
# echo "$SIZE: "`dirname "$TRACK";curseyellow`/`filename "$TRACK";cursenorm`""
echo "$SIZE: "`curseyellow;cursebold;filename "$TRACK";cursenorm`
echo "`cursered`del \"$TRACK\"`cursenorm`"
MP3INFO=`mp3info "$TRACK"`
echo "$MP3INFO" |
grep -v "^File: " |
sed "s+[[:alpha:]]*:+`cursemagenta`\0`cursenorm`+g" |
# sed "s+\(File:[^ ]* \)\(.*\)+`curseblue`\1 `curseblue`\2+"
/usr/bin/time -f "%e seconds ( Time: %E CPU: %P Mem: %Mk )" playmp3andwait "$TRACK"
echo
echo "--------------------------------------"
echo
