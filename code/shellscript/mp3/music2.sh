## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# find /stuff/mp3s/ /stuff/mirrors/ /mnt/*/RECLAIM /mnt/*/reclaim /mnt/big/winmxdownloads /mnt/big/mutella_downloads -iname "*.mp3" -or -iname "*.ogg" -not -size 0 |
find /stuff/mp3s/ /stuff/mirrors/ /mnt/big/winmxdownloads/ /mnt/big/mutella_downloads/ -iname "*.mp3" -or -iname "*.ogg" -not -size 0 |
# ungrep "__INCOMPLETE__" |
notindir horrid dontplay _dontplay part |
## Sort them by filename (rather than path)
sortpathsbyfilename |
# sortpathsbylastdirname |
cat > $JPATH/music/list.m3u
