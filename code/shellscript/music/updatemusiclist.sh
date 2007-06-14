## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# find /stuff/mp3s/ /stuff/mirrors/ /mnt/*/RECLAIM /mnt/*/reclaim /mnt/big/winmxdownloads /mnt/big/mutella_downloads -iname "*.mp3" -or -iname "*.ogg" -not -size 0 |
# SEARCHDIRS="/stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /mnt/big/winmxdownloads/ /mnt/big/mutella_downloads/ /mnt/big/bittorrent_downloads/got /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/gtk-gnutella_downloads /mnt/big/cds /mnt/big/out /mnt/big/irate_downloads/"
# SEARCHDIRS="/stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /stuff/out/ /stuff/share/ /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/cds /stuff/otherfiles/downloads/"
SEARCHDIRS="$MUSIC_SEARCH_DIRS /stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /stuff/out/ /stuff/share/ /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/cds /stuff/otherfiles/downloads/ /mnt/hda2/stuff/mp3s /stuff/share/*/"

find $SEARCHDIRS -type f -iname "*.mp3" -or -iname "*.ogg" -or -iname "*.it" -or -iname "*.xm" -or -iname "*.ra" -or -iname "*.wma" -not -size 0 |
# ungrep "__INCOMPLETE__" |
notindir horrid dontplay _dontplay part lessons working corrupted |
ungrep INCOMPLETE |
grep -i -v "pimsleur" |
## Sort them by filename (rather than path)
sortpathsbyfilename |
# sortpathsbylastdirname |
tee $JPATH/music/list.m3u
