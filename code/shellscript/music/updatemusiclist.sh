#!/bin/sh
## The extra slash on mp3s/ ensures find follows the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# [ "$MUSIC_SEARCH_DIRS" ] || MUSIC_SEARCH_DIRS="/stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /stuff/out/ /stuff/share/ /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/cds /stuff/otherfiles/downloads/ /mnt/hda2/stuff/mp3s /stuff/share/*/"

[ "$MUSIC_EXTS_REGEXP" ] || MUSIC_EXTS_REGEXP="\(mp3\|ogg\|it\|xm\|ra\|wma\|flac\)"
[ "$MUSIC_IGNORE_REGEXP" ] || MUSIC_IGNORE_REGEXP="\(pimsleur\|/INCOMPLETE/\|/RECLAIM\|/dontplay/\|/horrid/\|\/share/sounds\|/lessons/\|/corrupted/\|/ktorrent_working/\)"

# find $MUSIC_SEARCH_DIRS -type f -iname "*.mp3" -or -iname "*.ogg" -or -iname "*.it" -or -iname "*.xm" -or -iname "*.ra" -or -iname "*.wma" -or -iname "*.flac" -not -size 0 |
locate -e -i -r "\.$MUSIC_EXTS_REGEXP"'$' |
grep -v -i "$MUSIC_IGNORE_REGEXP" |
filesonly | ## locate -e deals with non-existent files, but i don't want existing symlinks creating duplicates either
## Sort them by filename (rather than path)
# sortpathsbyfilename |
sortpathsbylastdirname |
dog $JPATH/music/all.m3u

cat $JPATH/music/all.m3u |
tee $JPATH/music/list.m3u   ## << This is the file xmms reads from, but xmms also overwrites it when playlist is edited.

