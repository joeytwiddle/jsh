# Breaks on Unix:

if test $JM_ADVANCED_DU; then
	DUCOM="du -skx"
else
	DUCOM="du -sk"
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
	# echo -e "$X\t"`ls -artFd --color "$Y"`
	echo "$X	"`ls -dF "$Y"`
done

# files
# du -sk *
