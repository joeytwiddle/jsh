## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
find /stuff/mp3s/ /mnt/filfirin/gone_consume /mnt/big/gone_consume /mnt/big/winmxdownloads /mnt/big/mutella_downloads -iname "*.mp3" -not -size 0 |
# ungrep "__INCOMPLETE__" |
notindir horrid dontplay _dontplay |
## Sort them by filename (rather than path)
# sortpathsbyfilename |
sortpathsbylastdirname |
cat > $JPATH/music/list.m3u
