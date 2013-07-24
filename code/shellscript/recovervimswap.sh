#!/bin/sh
# jsh-ext-depends-ignore: compare sudo
# jsh-ext-depends: fuser realpath diff cmp
# jsh-depends: trimempty jshwarn takecols drop del age cursenorm jshinfo filesize verbosely dropcols absolutepath cursecyan diffhighlight findjob
# jsh-depends-ignore: realpath vimdiff pid swap hwibot
## Appears stable =)



# recovervimswap is currently hanging due my modified recover.vim plugin.
# Until this is resolved, we had better not use recovervimswap!
if [ "$1" = -thenvim ]
then shift ; vim "$@"
fi
exit



RVS_USE_AGE=true

## BUG: if multiple txtfiles are given, VIMAFTER gets cleared if only *one* of them is vimdiffed, whereas it should only be cleared if all of them were vimdiffed
## Will rarely fail on final dir if the file is a symlink elsewhere, but if we do realpath we may miss a swapfile at the given path or one in an intermediate directory.  Rather than checking all, we always use the local given path, and leave the handling of swapfiles in symlinked dirs to the user.
## TODO: The intermediate swapfiles are relevant but the one that makes vim annoying is the final target, I suspect the vim executable ignores the others.  So just do a realpath.

## VIMAFTER may need updating for diffandask - where it was muting unneccessary vim after a vimdiff, there may now have been no vimdiff!
## I have actually got used to VIMAFTER not working anyway, so we could just remove it altogether.
## I kind of like that there are two processes: fixing the swapfiles, then opening the original requested set; since vimdiff's colors are distracting, once I have fixed any diffs, I am happy to reset vim (I quit vimdiff, so then vim runs)!

## TODO: VIMAFTER is mixing various concepts: wantToVimAfter, safeToVimAfter and mustDealWithSwapDiffs.
## Runs a recovervimswap check, interactively, then runs vim afterwards.
if [ "$1" = -thenvim ]
then VIMAFTER=true; INTERACTIVE=true; shift
# then INTERACTIVE=true; shift
fi

# [ ! "$DIFFCOM" ] && DIFFCOM=vimdiff

## Did not work!  Because we were doing while read SWAPFILE from the find.
## TESTING: Now we are trying a for instead.
[ ! "$DIFFCOM" ] && DIFFCOM=diffandask
diffandask() {
	(
	echo
	age "$1"
	age "$2"
	echo
	echo "The swapfile has the following changes:"
	diff "$1" "$2" | diffhighlight
	# echo "Red lines are missing from the swapfile, green lines are added by the swapfile."
	echo "The swapfile will *remove* the red lines, and *add* the green lines."
	) | more
	echo -n "Do you want to (U)se these changes, (D)rop these changes, or (V)imdiff them? "
	read userSays
	case "$userSays" in
		U|u)
			cp -f "$2" "$1"
		;;
		D|d)
			del "$2"
		;;
		V|v)
			vimdiff "$1" "$2"
		;;
		*)
			echo "Doing nothing.  Recovered file is left: $2"
		;;
	esac
	sleep 1
}

NL="
"
for X
do

	if [ ! -f "$X" ]
	then
		jshwarn "Not a file: $X"
		continue
	fi

	DIR=`dirname \`realpath "$X"\``
	FILE=`basename "$X"`
	# SWAPS=`countargs $DIR/.$FILE.sw?`
	## TODO: The leading . is not necessary if file is a .file
	LOOKFOR="$DIR/`echo ".$FILE"'.sw?' | sed 's+^\.\.+.+'`"

	# # SWAPS=` find "$DIR"/ -maxdepth 1 -name "$LOOKFOR" | countlines `
	# SWAPFILES=` find "$DIR"/ -maxdepth 1 -name "$LOOKFOR" `
	# SWAPS=`printf "%s" "$SWAPFILES" | countlines`
# 
	# if [ $SWAPS -lt 1 ]
	# then echo "No swapfiles found for $X"
# 
	# ## This didn't get caught one time when I thought it should have.  The file might have been a .file
	# elif [ $SWAPS -gt 1 ]
	# then echo "More than one swapfile found for $X.  TODO: can recover by referring to swapfile directly."

	# for SWAPFILE in "$DIR"/"$FILE".sw* "$DIR"/."$FILE".sw*
	# do

	## BUG: changes to VIMAFTER are lost due to |while, so avoid this somehow with exec.
	
	# find "$DIR"/ -maxdepth 1 -name "$LOOKFOR" |
	# while read SWAPFILE
	for SWAPFILE in $LOOKFOR
	do

		[ -e "$SWAPFILE" ] || continue

		## We should do: SWAPFILE=`realpath "$SWAPFILE"` here?

		if [ "$INTERACTIVE" ] && verbosely fuser -v "$SWAPFILE"
		then
			jshwarn "Swapfile is already open; quitting"
			## List the guilty processes, for convenience:
			# fuser "$SWAPFILE" 2>/dev/null | tr ' ' '\n' |
			fuser -v "$SWAPFILE" 2>&1 | drop 1 | head -n 5 | dropcols 1 2 4 5 | takecols 1 | trimempty |
			tee /tmp/xpq |
			while read pid; do findjob "$pid"; done
			## BUG: isn't this VIMAFTER= guaranteed to be forgotten outside of this fine | while loop?  Is that even relevant, since we exit just below?
			VIMAFTER=
			sleep 4
			exit 0 ## everything happened as it should have, assume the call to this script "succeeded"
			# exit 3 ## not strong enough inside this | while !  (Not sure why I thought that, maybe this exit works fine, but editandwait's runoneof was running viminxterm then vim so it looked like VIMAFTER was left set the second time round <- ??!  Isn't that style of find | guarantted to pass either 0 or 1 lines?  No, if LOOKFOR contains "?" or "*"!)
			## BUG TODO: Wait I investigated, and I do think that, and it's a problem, because we seem to break out and VIMAFTER=true, and we open the file despite the fact we've warned the user it's already opened, and refused to open it.  :P  Maybe the outer for loop contributes to our problem here.
		fi

		if [ -n "$RVS_USE_AGE" ]
		then
			if newer "$X" "$SWAPFILE"
			then
				jshinfo "Deleting old swapfile: $SWAPFILE"
				del "$SWAPFILE"
				continue
			else
				jshinfo "Swapfile is newer than file!"
			fi
		fi

		## Choose name for swapfile
		N=1
		while [ -e "$X.recovered.$N" ]
		do N=`expr $N + 1`
		done
		RECOVERFILE="$X.recovered.$N"

		jshinfo "Recovering swapfile $SWAPFILE to $RECOVERFILE"

		[ "$COLUMNS" ] && [ "$COLUMNS" -lt 80 ] && jshwarn "recovervimswap has been known to stall when COLUMNS is small!"

		## TODO: Could grep following for "^Recovery completed"
		SEND_ERR=/dev/null
		## FIXED: I think we fixed this by specifying the swapfile~ If there is more than 1 swapfile, vim may ask user to choose which one to recover (somehow it does read answer from terminal not stdin); but user cannot see message if we hide output!
		## This can give errors for other reasons (e.g. "cannot write .viminfo") even if the recovery went fine.
		## In that case, the old method would keep creating identical recover files but never deleting the swapfile!
		## So we don't check vim's exit code (until I fix this problem on my gentoo!)
		verbosely vim --noplugin -r "$SWAPFILE" -c ":wq $RECOVERFILE" > "$SEND_ERR"

		## Filthy hack to recover old swapfiles written by my old 32bit OS (makes use of my 32bit debian install in /mnt/hwibot)
		## We use absolutepath although we could have used cd.  BUG: Won't work for paths which fail to resolve in the chroot.
		## ssh "$USER@127.0.0.1" -p 22 was not working quite right, so we use sudo chroot su!
		[ "$?" = 0 ] || verbosely sudo chroot /mnt/hwibot su - joey -c "vim --noplugin -r \"$SWAPFILE\" -c \":wq `absolutepath "$RECOVERFILE"`\"" > "$SEND_ERR"

		if [ -f "$RECOVERFILE" ] && [ `filesize "$RECOVERFILE"` -gt 0 ]
		then
			## Recovery succeeded.  Let's give the recovered file the date it should have:
			touch -r "$SWAPFILE" "$RECOVERFILE"
			# echo "Successfully recovered $SWAPFILE to $RECOVERFILE, so deleting former:"
			# del "$SWAPFILE"
			echo "Successfully recovered $SWAPFILE to $RECOVERFILE"
			del "$SWAPFILE" >/dev/null &
			if cmp "$X" "$RECOVERFILE" > /dev/null
			then
				echo "Recovered file $RECOVERFILE is identical to original, so removing."
				sleep 0.5   # If this message disappears immediately, the user may not know what the conclusion was!
				rm "$RECOVERFILE" ## remove temp file
				## Now if we are really confident about this script, we could
				## delete the swapfile, or get vim to.
				cursecyan
				VIMAFTER=true
			else
				if newer "$SWAPFILE" "$X"
				then jshwarn "Swapfile is *newer* than $X - you probably want its contents!"
				# else you probably don't :P
				fi
				if [ "$INTERACTIVE" ]
				then
					jshinfo "Recovered non-identical swapfile; running $DIFFCOM ..."
					## Hmmm vim doesn't really like running whilst inside a while read loop!  ("not a terminal")
					[ "$DIFFCOM" = diffandask ] || jshwarn "If you fix the problem now, please delete the recovered file:"
					echo "del \"`realpath "$RECOVERFILE"`\""
					# sleep 30
					"$DIFFCOM" "$X" "$RECOVERFILE"
					# verbosely xterm -e vimdiff "$X" "$RECOVERFILE" &
					## We don't really want it to become a background process!
					# verbosely unj vimdiff "$X" "$RECOVERFILE"
					wait
					## Why was this here?  VIMAFTER=
					# jshwarn "Vimdiff complete; deleting recoverfile; undelete it if you wanted it!!"
					# verbosely del "$RECOVERFILE"
				else
					# echo "Not identical, but recovered, so you can remove the swapfile with:"
					jshwarn "Recovered file differs from current; compare them with:"
					## Again, if the recovered file exists and is not empty,
					## then its pretty likely the swapfile is redundant, and can be removed.  =)
					cursecyan
					# vimdiff "$X" "$RECOVERFILE"
					echo "vimdiff $X $RECOVERFILE"
					echo "del $RECOVERFILE"
					## TODO: For some reason as a user I feel I will be asked again
					## whether to apply the changes.  I.e. I use vimdiff to inspect,
					## but let this script do the merge.
					## Why was this here?  VIMAFTER=
				fi
			fi
			cursenorm
		else
			echo "Some problem recovering swap file (for) $X"
		fi

	done

done

if [ "$VIMAFTER" ]
then
	jshinfo "[recovervimswap] running: vim $*"
	vim "$@"
else
	: # jshinfo "[recovervimswap] no vim $*"
fi

## Doesn't work:
# vim +":recover
# :w tmp
# :q" "$1"
