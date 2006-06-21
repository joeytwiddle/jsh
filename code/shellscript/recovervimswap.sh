## Appears stable =)

## BUG: if multiple txtfiles are given, VIMAFTER gets cleared if only *one* of them is vimdiffed, whereas it should only be cleared if all of them were vimdiffed

## Runs a recovervimswap check, interactively, then runs vim afterwards.
if [ "$1" = -thenvim ]
then VIMAFTER=true; INTERACTIVE=true; shift
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

	DIR=`dirname "$X"`
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
	
	find "$DIR"/ -maxdepth 1 -name "$LOOKFOR" |
	while read SWAPFILE
	do

		if [ "$INTERACTIVE" ] && verbosely fuser -v "$SWAPFILE"
		then
			jshwarn "Swapfile is already open; quitting"
			VIMAFTER=
			sleep 4
			exit 3 ## not strong enough inside this | while !
		fi

		N=1
		while [ -e "$X.recovered.$N" ]
		do N=`expr $N + 1`
		done
		RECOVERFILE="$X.recovered.$N"

		jshinfo "Recovering swapfile $SWAPFILE to $RECOVERFILE"

		## TODO: Could grep following for "^Recovery completed"
		SEND_ERR=/dev/null ## BUG: if there is more than 1 swapfile, vim may ask user to choose which one to recover (somehow it does read answer from terminal not stdin); but user cannot see message if we hide output!
		if verbosely vim +":w $RECOVERFILE$NL:q" -r "$SWAPFILE" > "$SEND_ERR" 2>&1 &&
			 [ -f "$RECOVERFILE" ]
		then
			if [ "$INTERACTIVE" ]
			then
				echo "Successfully recovered $SWAPFILE to $RECOVERFILE, so deleting former:"
				# verbosely touch -r "$SWAPFILE" "$RECOVERFILE"
				touch -r "$SWAPFILE" "$RECOVERFILE"
				# verbosely del "$SWAPFILE"
				del "$SWAPFILE"
			else
				echo "Successfully recovered $SWAPFILE to $RECOVERFILE, so you can:"
				# echo del $DIR/.$FILE.sw?
				# echo del "$DIR/.$FILE.swp"
				# echo del "$DIR/$LOOKFOR"
				echo `cursecyan`del "$SWAPFILE"`cursenorm`
				## Could probably delete swapfile now, if we only knew its name!  (Use del)
			fi
			if cmp "$X" "$RECOVERFILE" > /dev/null
			then
				echo "Recovered swap $RECOVERFILE is identical to original, so removing."
				rm "$RECOVERFILE" ## remove temp file
				## Now if we are really confident about this script, we could
				## delete the swapfile, or get vim to.
				cursecyan
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
					echo "Not identical, but recovered, so you can remove the swapfile with:"
					## Again, if the recovered file exists and is not empty,
					## then its pretty likely the swapfile is redundant, and can be removed.  =)
					cursecyan
					# vimdiff "$X" "$RECOVERFILE"
					echo "vimdiff $X $RECOVERFILE"
					echo "del $RECOVERFILE"
				fi
			fi
			cursenorm
		else
			echo "Some problem recovering swap file (for) $X"
		fi

	done

done

if [ "$VIMAFTER" ]
then vim "$@"
fi

## Doesn't work:
# vim +":recover
# :w tmp
# :q" "$1"
