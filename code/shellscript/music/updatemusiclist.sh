#!/bin/sh
## The extra slash on mp3s/ ensures find follows the link (if not use -follow)
## [ No use memoing find since the sort takes time, need to make into a fn then memo that. ]
# [ "$MUSIC_SEARCH_DIRS" ] || MUSIC_SEARCH_DIRS="/stuff/mp3s/ /stuff/mp3sfor/ /stuff/mirrors/ /stuff/out/ /stuff/share/ /mnt/big/out /mnt/big/toconsume /mnt/big/gone_consume /mnt/big/consume_then_write /mnt/big/cds /stuff/otherfiles/downloads/ /mnt/hda2/stuff/mp3s /stuff/share/*/"

[ -z "$JSH_MUSIC_DIR" ] && JSH_MUSIC_DIR="$HOME/Music/"

[ -z "$JSH_ALL_AUDIO_FILES" ] && JSH_ALL_AUDIO_FILES="$JSH_MUSIC_DIR/jsh_audio_files.m3u"

# We actually write to a lot of other places at the bottom too.

[ "$MUSIC_EXTS_REGEXP" ] || MUSIC_EXTS_REGEXP="\(mp3\|ogg\|xm\|ra\|wma\|flac\|m4a\|m4p\|mod\|it\)"
[ "$MUSIC_IGNORE_REGEXP" ] || MUSIC_IGNORE_REGEXP="\(/INCOMPLETE/\|/RECLAIM\|/dontplay/\|/horrid/\|/lessons/\|/corrupted/\|/ktorrent_working/\|/sounds/\|\/samples\|/usr/src/\|/boot/grub/\|/usr/lib/grub/\|/games/\)" # pimsleur\|
## /sounds/ catches /stuff/share/sounds, javascript/contrib/lazeroids-node/public/sounds, orona/0.1.91/package/public/sounds, /stuff/media/sounds
## /samples/ catches .enlightenment/themes/abtoenalloygreenJoey/sound/samples, /usr/share/lmms/samples
## /usr/src/ and /boot/grub/ speed up stripping of non-tracker .mod files

# find $MUSIC_SEARCH_DIRS -type f -iname "*.mp3" -or -iname "*.ogg" -or -iname "*.it" -or -iname "*.xm" -or -iname "*.ra" -or -iname "*.wma" -or -iname "*.flac" -not -size 0 |
locate -e -i -r "\.$MUSIC_EXTS_REGEXP"'$' |
grep -v -i "$MUSIC_IGNORE_REGEXP" |
filesonly | ## locate -e deals with non-existent files, but i don't want existing symlinks creating duplicates either
# sed 's+^.*\(/stuff/.*\)+\1+' |
# sed 's+^.*/\(share/.*\)+/stuff/\1+' |
sed 's+/mnt/[^/]*/stuff/+/stuff/+' |
sed 's+.*/share/+/stuff/share/+' |
sed 's+.*/mp3sfor/+/stuff/mp3sfor/+' |
dog "$JSH_ALL_AUDIO_FILES"

## Many files with .mod extension are not actually tracker files!  We must
## check all these files because my XMMS modplug plugin sometimes has an audio
## lockup if it tries to play a non-tracker file.
if which file >/dev/null
then
	(
		TRACKER_FORMATS="\.\(it\|mod\|xm\)$"
		cat "$JSH_ALL_AUDIO_FILES" | grep "$TRACKER_FORMATS" |
		while read trackerFile
		do
			## We allow unrecognised "data" files, or recognised things if they are tracker files :)
			if file "$trackerFile" | grep -i "\(: data$\|tracker\)" >/dev/null
			then echo "$trackerFile"
			else echo "Dropping non-tracker file: $trackerFile" >&2
			fi
		done
		cat "$JSH_ALL_AUDIO_FILES" | grep -v "$TRACKER_FORMATS" ## everything else we didn't check
	) | dog "$JSH_ALL_AUDIO_FILES"
fi

cat "$JSH_ALL_AUDIO_FILES" |
## Sort them by filename (rather than path)
# sortpathsbyfilename |
sortpathsbylastdirname |
dog "$JSH_ALL_AUDIO_FILES"



## Personally I like to generate a shuffled playlist too

# We write to some other handy files:
outDir="$HOME/Music/"
if [ ! -d "$outDir" ]
then outDir="$JPATH/music"
fi
mkdir -p "$OUTDIR"

cat "$JSH_ALL_AUDIO_FILES" | randomorder > $outDir/list.m3u   ## << This is the file xmms reads from, but xmms also overwrites it when playlist is edited.

cp -f $outDir/list.m3u $outDir/all-shuffled.m3u   ## A copy in case I temporarily mess my playlist up

cat "$outDir/list.m3u"   ## Other scripts, for example randommp3, run "memo updatemusiclist" to get a playlist.

