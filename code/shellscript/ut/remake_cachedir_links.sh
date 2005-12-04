## This has rather overgrown its original purpose; to extract cachefiles
## It now tries crazy things like suggesting removal of duplicates etc.
## But I think the process_cachedir.sh script is much better than this one.

CACHEDIR="/home/joey/linux/.loki/ut/Cache"

# FILEDIRS="/stuff/software/games/unreal/server/"
# FILEDIRS="/stuff/software/games/unreal/server/maps /home/oddjob2/ut_server/ut-server/ /stuff/software/games/unreal/server/files /mnt/big/ut"
# FILEDIRS="/stuff/software/games/unreal/server/ /home/oddjob2/ut_server/ut-server/ /mnt/big/ut_win"
FILEDIRS="/stuff/software/games/unreal/server/maps /stuff/software/games/unreal/server/files /home/oddjob2/ut_server/ut-server/ /mnt/big/ut_win"

## Optional, definitely slower!
# LOST_CACHEFILES_LIST=/home/oddjob2/ut_server/lost_cachefiles_list.txt

. importshfn rmlink
. importshfn verbosely
. importshfn error
. importshfn countlines
. importshfn jshinfo
. importshfn memo
. importshfn rememo
. importshfn jgettmpdir

. jgettmpdir -top

## Remove any existing links from cachedir (useful e.g. for purging old broken links)
# find "$CACHEDIR/" -type l |
# # foreachdo verbosely rmlink
# # withalldo verbosely rmlink
# foreachdo rmlink

FINDFILE=/tmp/ff.temp
memo -t "10 minutes" find $FILEDIRS -type f > "$FINDFILE"

cat "$CACHEDIR"/cache.ini |
# catwithprogress "$CACHEDIR"/cache.ini |
dos2unix | grep = | sed 's+=+ +' |

# randomorder |
catwithprogress |

## For debugging:
# grep BDBMapVote302.u |

while read SUM FNAME
do

	BOWFILE="$CACHEDIR"/"$SUM".uxx

	if [ -L "$BOWFILE" ] && [ -e "$BOWFILE" ]
	then
		debug "Skipping already working $BOWFILE"
		## Optional: check filename matches...
		# TARGETFILE=`realpath "$BOWFILE"`
		# TARGETNAME=`filename "$TARGETFILE"`
		# if [ ! "$TARGETNAME" = "$FNAME" ]
		# then
			# TARGETDIR=`dirname "$TARGETFILE"`
			# jshwarn "Cachefile $SUM.uxx's name $FNAME does not match its current target's name: $TARGETNAME"
			# jshwarn "  $TARGETFILE"
			# # echo "mv \"$TARGETFILE\" \"$TARGETDIR/$FNAME\""
			# echo "mv \"$TARGETFILE\" \"$TARGETDIR/$FNAME\".tmp"
			# echo "mv \"$TARGETDIR/$FNAME\".tmp \"$TARGETDIR/$FNAME\""
			# echo "rmlink \"$BOWFILE\""
		# fi
	else
		# continue

		FNAMEREGEXP=`toregexp "$FNAME"`

		TARGETS=`
			# find $FILEDIRS -type f -iname "$FNAME"
			# memo find $FILEDIRS -type f | grep -i "/$FNAMEREGEXP$"
			cat "$FINDFILE" | grep -i "/$FNAMEREGEXP$"
		`

		NUMTARGETS=`printf "%s" "$TARGETS" | countlines`

		TARGET_TO_USE=`printf "%s" "$TARGETS" | head -n 1`

		if [ -f "$TARGET_TO_USE" ]
		then
			if [ "$NUMTARGETS" -gt 1 ]
			then
				jshwarn "More than 1 option for $FNAME:"
				cksum $TARGETS |
				while read A B FILE
				do echo "# $A $B del \"$FILE\""
				done
				# echo "$TARGETS" >&2
				# echo "$TARGETS" | withalldo cmp >&2 ||
				# error "The different options differ!"
				# if ! echo "$TARGETS" | withalldo cmp >&2
				# if ! cmp $TARGETS >&2
				# then error "The different options differ!"
				# else echo "$TARGETS" | drop 1 | grep "/stuff/software/games/unreal/server/files/" | withalldo echo del
				# fi
			fi
			# jshinfo "$NUMTARGETS for $FNAME, using $TARGET_TO_USE"
			# ln -sf "$TARGET_TO_USE" "$BOWFILE"
			if [ ! -e "$BOWFILE" ] || [ -L "$BOWFILE" ]
			then
				# ln -sf "$TARGET_TO_USE" "$BOWFILE"
				# verbosely ln -sf "$TARGET_TO_USE" "$BOWFILE"
				echo "ln -sf \"$TARGET_TO_USE\" \"$BOWFILE\""
			else
				error "$BOWFILE already exists but it not a symlink!"
			fi
		else
			error "No target for $FNAME ($SUM)"
			# if [ -e "$BOWFILE" ]
			# then ls -l "$BOWFILE"
			# fi
			:
			if [ "$LOST_CACHEFILES_LIST" ]
			then
				SIZEBEFORE=`filesize "$LOST_CACHEFILES_LIST"`
				( cat "$LOST_CACHEFILES_LIST" | grep -v '^'`toregexp "$FNAME"`'$' ; echo "$FNAME" ) | dog "$LOST_CACHEFILES_LIST"
				SIZEAFTER=`filesize "$LOST_CACHEFILES_LIST"`
				if [ "$SIZEAFTER" -lt "$SIZEBEFORE" ]
				then error "Problem with regexp: " `toregexp "$FNAME"`
				fi
			fi
		fi

	fi

done
