## TODO: Can we detect and handle svn mvs?  Eh but what about a move and then a modify (usually the case with .java files for example).

## TODO: Should we leave the commit until last?  (Let the user commit the whole thing, once the adds/rms have been prepared.)

if [ "$1" = -m ]
then MODIFIED_MESSAGE="$2"; shift; shift
else MODIFIED_MESSAGE="modified"
fi

jshinfo "If you want to make the latest svn revision look exactly like this directory, try:"
# jshwarn "(This version does not handle svn moves.)"

svn status |

while read STATUS FILEPATH
do

	case "$STATUS" in

		\?)
			echo "svn add \"$FILEPATH\""
		;;

		M)
			echo "svn commit -m '$MODIFIED_MESSAGE' \"$FILEPATH\""
		;;

		!)
			echo "svn delete \"$FILEPATH\""
		;;

		*)
			jshwarn "Sorry I don't know how to handle: $STATUS $FILEPATH"
		;;

	esac

done
