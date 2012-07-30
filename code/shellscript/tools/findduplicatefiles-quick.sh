## jsh-help: A simplified implementation of findduplicatefiles.
## jsh-help: It checks for files with duplicate size before checking contents, although findduplicatefiles now does that too.
## jsh-help: NOT entirely thorough - if there are many files of the same size, only some of which are duplicates, the duplicates may not get matched if they do not appear sequentially in the input list.
## jsh-help: Note: the uncommented incarnation is super paranoid (uses cksum _and_ cmp), and checks that files _have_the_same_name_, which is just a feature I wanted for UT files, but probably not in general for this script.  So DONE: strip it out

find "$@" -type f -printf "%s %p\n" |
## Doesn't work:
# find-typef_avoiding_stale_handle_error "$@" -printf "%s %p\n" |
## I think sort -k 2 is inherent in above :)
sort -n -k 1 |
# catwithprogress |
while read SIZE FILE
do
	if [ "$LASTSIZE" = "$SIZE" ]
	then
		# jshinfo "Comparing ($SIZE) $LASTFILE $FILE ..."
		if cmp "$LASTFILE" "$FILE" >/dev/null
		then

			# LASTSUM=`cksum "$LASTFILE" | takecols 1 2`
			# SUM=`cksum "$FILE" | takecols 1 2`
			# if [ "$SUM" = "$LASTSUM" ]
			# then

				# if [ `filename "$LASTFILE"` = `filename "$FILE"` ]
				# then
					# jshwarn "You could remove match with $LASTFILE:"
					# echo "del \"$FILE\""
					# # jshinfo "Identical; removing latter."
					# # jshwarn "Identical; removing match with $LASTFILE:"
					# # del "$FILE"
				# else
					# error "$LASTFILE and $FILE match although their names do not!"
					# # echo "del \"$FILE\""
				# fi

			# else
				# cksum "$LASTFILE" "$FILE" >&2
				# # . errorexit "cmp said match but cksum did not!" ## Untested anyway; does it really exit?!  In all styles of sh?
				# error "Should Not Happen!!  cmp said match but cksum did not!"
			# fi

			echo "This:    $LASTFILE"
			echo "Matches: $FILE"

		else
			# jshinfo "Differ although size $SIZE matches."
			## Do we compare first with size-matches or all closest pairs?  Latter probably best.  This could be made optional.
			LASTSIZE="$SIZE"
			LASTFILE="$FILE"
		fi
		# echo >&2
	else
		LASTSIZE="$SIZE"
		LASTFILE="$FILE"
	fi
done
