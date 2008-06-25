## The extra slash on mp3s/ ensures find follow the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# [ "$MUSIC_SEARCH_DIRS" ] || MUSIC_SEARCH_DIRS="/stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /stuff/out/ /stuff/share/ /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/cds /stuff/otherfiles/downloads/ /mnt/hda2/stuff/mp3s /stuff/share/*/"

# find $MUSIC_SEARCH_DIRS -type f -iname "*.mp3" -or -iname "*.ogg" -or -iname "*.it" -or -iname "*.xm" -or -iname "*.ra" -or -iname "*.wma" -not -size 0 |
locate -i -r "\.\(mp3\|ogg\|it\|xm\|ra\|wma\)$" |
# ungrep "__INCOMPLETE__" |
notindir horrid dontplay _dontplay part lessons working corrupted |
ungrep INCOMPLETE |
grep -i -v "pimsleur" |
## Sort them by filename (rather than path)
sortpathsbyfilename |
# sortpathsbylastdirname |
dog $JPATH/music/list.m3u

cat $JPATH/music/list.m3u
