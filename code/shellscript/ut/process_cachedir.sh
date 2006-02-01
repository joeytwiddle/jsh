CACHEDIR="$HOME/.loki/ut/Cache"

DESTMAPDIR=/stuff/software/games/unreal/server/maps
DESTFILEDIR=/stuff/software/games/unreal/server/files/new

FILEDIRS="$DESTMAPDIR /stuff/software/games/unreal/server/files /home/oddjob2/ut_server/ut-server/ /mnt/big/ut_win_pure"

if [ "$1" = -delnew ]
then shift; DELNEW=true
fi

## Optional:
# LOST_CACHEFILES_LIST=/home/oddjob2/ut_server/lost_cachefiles_list.txt

. importshfn rmlink
. importshfn verbosely
. importshfn error
. importshfn countlines
. importshfn jshinfo

## Remove any existing links from cachedir (useful e.g. for purging old broken links)
# find "$CACHEDIR/" -type l |
# # foreachdo verbosely rmlink
# # withalldo verbosely rmlink
# foreachdo rmlink

cat "$CACHEDIR"/cache.ini |
# catwithprogress "$CACHEDIR"/cache.ini |
dos2unix | grep = | sed 's+=+ +' |

# reverse |
# randomorder |
catwithprogress | ## later = better = more representative and fewer buffers; but better representation might be by line progress rather than byte progress...

## For debugging:
# grep BDBMapVote302.u |

while read SUM FNAME
do

	BOWFILE="$CACHEDIR"/"$SUM".uxx

	if [ -L "$BOWFILE" ] && [ -e "$BOWFILE" ]
	then
		: # jshinfo "Skipping working $BOWFILE"
	else

		if [ -f "$BOWFILE" ]
		then

			## Escape shell-file-meta-chars (`*', `?', and `[]'):
			SEARCHFNAME=`echo "$FNAME" | sed 's+*+\\\\*+g ; s+\[+\\\\[+g ; s+\]+\\\\]+g ; s+\?+\\\\?+g'` ## []s work, rest untested
			[ "$DEBUG" ] && debug ">$FNAME< => >$SEARCHFNAME<"
			TARGETS=`
				# find $FILEDIRS -type f -name "$FNAME"
				# find $FILEDIRS -type f -iname "$FNAME"
				find $FILEDIRS -type f -iname "$SEARCHFNAME"
			`

			NUMTARGETS=`printf "%s" "$TARGETS" | countlines`

			TARGET_TO_USE=`printf "%s" "$TARGETS" | head -n 1`

			if [ -f "$TARGET_TO_USE" ]
			then
				if [ "$NUMTARGETS" -gt 1 ]
				then
					jshwarn "More than 1 option for $FNAME"
					# echo "$TARGETS" >&2
					echo "$TARGETS" | foreachdo jshinfo >&2
					# echo "$TARGETS" | withalldo cmp >&2 ||
					# error "The different options differ!"
					# if ! echo "$TARGETS" | withalldo cmp >&2
					if ! cmp $TARGETS >&2
					then error "The different options differ!"
					else echo "$TARGETS" | drop 1 | grep "/stuff/software/games/unreal/server/files/" | foreachdo echo del
					fi
				fi
				# jshinfo "$NUMTARGETS for $FNAME, using $TARGET_TO_USE"
				# ln -sf "$TARGET_TO_USE" "$BOWFILE"
				if [ ! -e "$BOWFILE" ] || [ -L "$BOWFILE" ]
				then verbosely echo ln -sf "$TARGET_TO_USE" "$BOWFILE"
				# then ln -sf "$TARGET_TO_USE" "$BOWFILE"
				else
					# jshinfo "$BOWFILE already exists but it not a symlink!  Should check against $TARGET_TO_USE"
					if [ -f "$BOWFILE" ] && [ -f "$TARGET_TO_USE" ] && cmp "$BOWFILE" "$TARGET_TO_USE" >&2
					then
						jshinfo "New cachefile matches existing file: $TARGET_TO_USE"
						TARGETNAME=`filename "$TARGET_TO_USE"`
						if [ ! "$TARGETNAME" = "$FNAME" ]
						then
							## TODO: could make this an info, and do it anyway...
							jshwarn "BUT cachefile's name $FNAME does not match target's $TARGETNAME"
						else
							# echo "rmlink \"$BOWFILE\""
							echo "del \"$BOWFILE\""
							echo "ln -s \"$TARGET_TO_USE\" \"$BOWFILE\""
						fi
					else
						jshwarn "New cachefile: $BOWFILE"
						jshwarn "mismatches existing: $TARGET_TO_USE"
					fi
				fi
			else
				jshinfo "Could not find existing target for $FNAME ; new file?!"
				# jshinfo "TODO: check cos it might be in server dir"
				if echo "$FNAME" | grep "^CTF" >/dev/null
				then TARGET_TO_USE="$DESTMAPDIR/$FNAME"
				else TARGET_TO_USE="$DESTFILEDIR/$FNAME"
				fi
				if [ "$DELNEW" ]
				then
					echo "del \"$BOWFILE\""
				else
					echo "mv -i \"$BOWFILE\" \"$TARGET_TO_USE\""
					echo "ln -s \"$TARGET_TO_USE\" \"$BOWFILE\""
				fi
				# if [ -e "$BOWFILE" ]
				# then ls -l "$BOWFILE"
				# fi
				:
				# if [ "$LOST_CACHEFILES_LIST" ]
				# then
					# SIZEBEFORE=`filesize "$LOST_CACHEFILES_LIST"`
					# ( cat "$LOST_CACHEFILES_LIST" | grep -v '^'`toregexp "$FNAME"`'$' ; echo "$FNAME" ) | dog "$LOST_CACHEFILES_LIST"
					# SIZEAFTER=`filesize "$LOST_CACHEFILES_LIST"`
					# if [ "$SIZEAFTER" -lt "$SIZEBEFORE" ]
					# then error "Problem with regexp: " `toregexp "$FNAME"`
					# fi
				# fi
			fi

		fi

	fi

done
