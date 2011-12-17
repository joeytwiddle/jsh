## This is fine for committing multiple revisions of one file
## But TODO sometimes I have a set of previous tarballs
## I want to commit the files inside each tarball as separate revisions
## Sometimes I will want to not commit all (e.g. no /bin/ or .class files or smelly old vim swapfiles) which could be done by a regexp
## The difficulty will be in detected which new files to add, and which old files were removed and should be removed from cvs in the latest version.

## tbh i thought cvscommitall might be a good name for a script (useful for the process i just described) which adds and commits all the files we have here as they are (and deletes any in cvs which are no in pwd)

## so WARN this script might get renamed to something else to make room for the cvscommitall described above

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = --help ]
then

cat << !

cvscommit [ <filename> | -auto ] <filepatterns>..

  Will first preview, then commit each of the files in <filepatterns> to cvs under
  the name <filename>.

  -auto will determine the filename by stripping any trailing version number.

!

exit 0

fi

FILENAME="$1"
# shift

# for X
# do
	# echo "$X"
# done

FILES_AS_ORDERED=` echolines "$@" `
FILES_BY_DATE=` echolines "$@" | sortfilesbydate `

echo "Files in date order:"
echo "$FILES_BY_DATE"

if [ "$FILES_AS_ORDERED" = "$FILES_BY_DATE" ]
then
	echo "  Date order and given order match."
else
	[ "$DEBUG" ] && echo "$FILES_AS_ORDERED" > /tmp/x
	[ "$DEBUG" ] && echo "$FILES_BY_DATE" > /tmp/y
	echo "  Date order and given order DO NOT match."
fi

# echo "Do you wish me to commit in this order under the filename '$FILENAME'?"
# 
# read ANS
# 
# if [ "$ANS" = y ]
# then
# 
	# for X
	# do
# 	
		# cp "$X" "$FILENAME"
		# cvs add "$FILENAME"
		# cvs commit -m "$X" "$FILENAME"
# 
	# done
# 
# fi

if [ -f "$FILENAME" ]
then
	jshwarn "$FILENAME exists but will be overwritten.  If it does not match the latest of those to be committed, you may with to back it up (or make it part of the pattern)."
fi

echo "Do you wish me to commit them in (d)ate order or (g)iven order under the filename '$FILENAME'?"

read ANS

# DO=verbosely
# DO=jshinfo
DO=echo

if [ "$ANS" = d ]
then echo "$FILES_BY_DATE"
elif [ "$ANS" = g ]
then echo "$FILES_AS_ORDERED"
else exit 0
fi |

while read X
do
	if [ "$FILENAME" = -auto ]
	then TOCOMMIT=`echo "$X" | sed "s+\.[0-9a-zA-Z+\-_]*$++"`
	else TOCOMMIT="$FILENAME"
	fi
	# $DO cp "$X" "$TOCOMMIT"
	$DO mv -f "$X" "$TOCOMMIT"
	# if [ ! "$DONE_ADD" ]
	# then
		$DO cvs add "$TOCOMMIT"
		# DONE_ADD=true
	# fi
	$DO cvs commit -m "$X" "$TOCOMMIT"
	$DO cvs edit "$TOCOMMIT"
	# $DO del "$X" "$TOCOMMIT"
done

