## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# find /stuff/mp3s/ /stuff/mirrors/ /mnt/*/RECLAIM /mnt/*/reclaim /mnt/big/winmxdownloads /mnt/big/mutella_downloads -iname "*.mp3" -or -iname "*.ogg" -not -size 0 |
find /stuff/mp3s/ /stuff/mirrors/ /mnt/big/winmxdownloads/ /mnt/big/mutella_downloads/ /mnt/big/bittorrent_downloads/got /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write/music -iname "*.mp3" -or -iname "*.ogg" -not -size 0 |
# ungrep "__INCOMPLETE__" |
notindir horrid dontplay _dontplay part lessons |
ungrep INCOMPLETE |
grep -i -v "pimsleur" |
## Sort them by filename (rather than path)
sortpathsbyfilename |
# sortpathsbylastdirname |
cat > $JPATH/music/list.m3u
