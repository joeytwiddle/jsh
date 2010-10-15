#!/bin/sh
## Appears stable =)

## BUG: if multiple txtfiles are given, VIMAFTER gets cleared if only *one* of them is vimdiffed, whereas it should only be cleared if all of them were vimdiffed
## Will rarely fail on final dir if the file is a symlink elsewhere, but if we do realpath we may miss a swapfile at the given path or one in an intermediate directory.  Rather than checking all, we always use the local given path, and leave the handling of swapfiles in symlinked dirs to the user.
## TODO: The intermediate swapfiles are relevant but the one that makes vim annoying is the final target, I suspect the vim executable ignores the others.  So just do a realpath.

## Runs a recovervimswap check, interactively, then runs vim afterwards.
if [ "$1" = -thenvim ]
then VIMAFTER=true; INTERACTIVE=true; shift
# then INTERACTIVE=true; shift
fi

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
	LOOKFOR=`echo ".$FILE"'.sw?' | sed 's+^\.\.+.+'`

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
	
	verbosely find "$DIR"/ -maxdepth 1 -name "$LOOKFOR" |
	while read SWAPFILE
	do

		## We should do: SWAPFILE=`realpath "$SWAPFILE"` here?

		if [ "$INTERACTIVE" ] && verbosely fuser -v "$SWAPFILE"
		then
			jshwarn "Swapfile is already open; quitting"
			## BUG: isn't this VIMAFTER= guaranteed to be forgotten outside of this fine | while loop?  Is that even relevant, since we exit just below?
			VIMAFTER=
			sleep 4
			exit 0 ## everything happened as it should have, assume the call to this script "succeeded"
			# exit 3 ## not strong enough inside this | while !  (Not sure why I thought that, maybe this exit works fine, but editandwait's runoneof was running viminxterm then vim so it looked like VIMAFTER was left set the second time round <- ??!  Isn't that style of find | guarantted to pass either 0 or 1 lines?  No, if LOOKFOR contains "?" or "*"!)
			## BUG TODO: Wait I investigated, and I do think that, and it's a problem, because we seem to break out and VIMAFTER=true, and we open the file despite the fact we've warned the user it's already opened, and refused to open it.  :P  Maybe the outer for loop contributes to our problem here.
		fi

		N=1
		while [ -e "$X.recovered.$N" ]
		do N=`expr $N + 1`
		done
		RECOVERFILE="$X.recovered.$N"

		jshinfo "Recovering swapfile $SWAPFILE to $RECOVERFILE"

		## TODO: Could grep following for "^Recovery completed"
		SEND_ERR=/dev/null ## FIXED: I think we fixed this by specifying the swapfile~ If there is more than 1 swapfile, vim may ask user to choose which one to recover (somehow it does read answer from terminal not stdin); but user cannot see message if we hide output!
		## This can give errors for other reasons (e.g. "cannot write .viminfo") even if the recovery went fine.
		## In that case, the old method would keep creating identical recover files but never deleting the swapfile!
		## So we don't check vim's exit code (until I fix this problem on my gentoo!)
		verbosely vim -r "$SWAPFILE" -c ":wq $RECOVERFILE" > "$SEND_ERR" 2>&1
		if [ -f "$RECOVERFILE" ] && [ `filesize "$RECOVERFILE"` -gt 0 ]
		then
			if [ "$INTERACTIVE" ]
			then
				echo "Successfully recovered $SWAPFILE to $RECOVERFILE, so deleting former:"
				# verbosely touch -r "$SWAPFILE" "$RECOVERFILE"
				touch -r "$SWAPFILE" "$RECOVERFILE"
				# verbosely del "$SWAPFILE"
				del "$SWAPFILE"
				VIMAFTER=true
			else
				echo "Successfully recovered $SWAPFILE to $RECOVERFILE, so you can:"
				# echo del $DIR/.$FILE.sw?
				# echo del "$DIR/.$FILE.swp"
				# echo del "$DIR/$LOOKFOR"
				echo `cursecyan`del "$SWAPFILE"`cursenorm`
				## Could probably delete swapfile now, if we only knew its name!  (Use del)
				VIMAFTER=true
			fi
			if cmp "$X" "$RECOVERFILE" > /dev/null
			then
				echo "Recovered swap $RECOVERFILE is identical to original, so removing."
				rm "$RECOVERFILE" ## remove temp file
				## Now if we are really confident about this script, we could
				## delete the swapfile, or get vim to.
				cursecyan
				VIMAFTER=true
			else
				if [ "$INTERACTIVE" ]
				then
					jshinfo "Recovered non-identical swapfile; running vimdiff..."
					## Hmmm vim doesn't really like running whilst inside a while read loop!  ("not a terminal")
					jshwarn "If you fix the problem now, please delete the recovered file:"
					echo "del \"`realpath "$RECOVERFILE"`\""
					# sleep 30
					verbosely vimdiff "$X" "$RECOVERFILE"
					# verbosely xterm -e vimdiff "$X" "$RECOVERFILE" &
					## We don't really want it to become a background process!
					# verbosely unj vimdiff "$X" "$RECOVERFILE"
					wait
					VIMAFTER=
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
					VIMAFTER=
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
