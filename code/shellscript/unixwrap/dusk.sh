# Breaks on Unix:

if test $JM_ADVANCED_DU; then
	DUCOM="du -skx"
else
	DUCOM="du -sk"
fi

if test $JM_COLOUR_LS; then
	# This is bad if the output is being streamed through autoamtion!
	LSCOM="ls -artFd --color"
else
	# Too slow on Unix ATM (and not enough for it ATM ;):
	LSCOM="fakels -d"
	# LSCOM="ls -dF"
	# LSCOM="echo"
fi

(

	ARGS="$@";
	if test "x$ARGS" = "x"; then
	  # ARGS="* .*";
	  # Yuk we need to strip out . and ..!
	  ARGS=""
	  for X in * .*; do
			if test ! "$X" = ".."; then
				# Uncomment this next if to keep this dir . (total)
				if test ! "$X" = "."; then
					echo "$X"
				fi
			fi
		done | while read X; do
			$DUCOM "$X"
		done
	else
		$DUCOM "$@"
	fi

) | sort -n -k 1 |

# Pretty printing
while read X Y; do
	printf "$X\t"
	$LSCOM "$Y"
done

# files
# du -sk *
