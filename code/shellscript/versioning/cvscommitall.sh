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

[ DO=1 ] cvscommitall [ <base_filename> | -auto ] <files>..

  Will batch commit each of the listed files to CVS under the base filename.

  Without DO=1 it actually only prints a preview of what would be done.

  -auto will determine the filename by stripping any trailing version number.

  Currently prompts the user to choose between date or given order.

    TODO: This should not mess with stdout!  Since a cmdlist comes after.
    TODO: Options -d -g to force one of the other could avoid that step.
    TODO: Auto is dodgy, check the code, it *could* commit different filenames!

  Example:

    cvscommitall cool.c old/cool.c.myversion*

!

exit 0

fi

BASEFILENAME="$1"

if [ "$BASEFILENAME" = -auto ]
then
	# Use the first filename and strip its last .* to generate the basename.
	BASEFILENAME=`echo "$2" | sed "s+\.[0-9a-zA-Z+\-_]*$++"`
	jshinfo "Guessed base filename $BASEFILENAME"
fi

FILES_AS_ORDERED=` echolines "$@" `
FILES_BY_DATE=` echolines "$@" | sortfilesbydate `



# DO=verbosely
# DO=jshinfo
# DO=echo

if [ "$DO" = 1 ]
then DO=verbosely
else
	DO=echo
	jshinfo "Trial run - will not act!"
fi



echo "$FILES_BY_DATE"
# Print after because long lists will hide the top
jshinfo "This list is in (d)ate order."

if [ "$FILES_AS_ORDERED" = "$FILES_BY_DATE" ]
then
	jshinfo "Date order and given order match."
else
	[ "$DEBUG" ] && echo "$FILES_AS_ORDERED" > /tmp/x
	[ "$DEBUG" ] && echo "$FILES_BY_DATE" > /tmp/y
	jshwarn "Date order and given order DO NOT match."
fi

# echo "Do you wish me to commit in this order under the filename '$BASEFILENAME'?"
# 
# read ANS
# 
# if [ "$ANS" = y ]
# then
# 
	# for X
	# do
# 	
		# cp "$X" "$BASEFILENAME"
		# cvs add "$BASEFILENAME"
		# cvs commit -m "$X" "$BASEFILENAME"
# 
	# done
# 
# fi

if [ -f "$BASEFILENAME" ]
then
	jshwarn "$BASEFILENAME exists but would be overwritten.  If it does not match the latest of those to be committed, you may with to back it up (or make it part of the pattern)."
	# TODO: We should just do this automatically.  Move it to a tempfile at the start, and back for one final commit, no - just leave it uncommited.
fi

echo "Do you wish me to commit them in (d)ate order or (g)iven order under the filename '$BASEFILENAME'?"

read ANS

if [ "$ANS" = d ]
then echo "$FILES_BY_DATE"
elif [ "$ANS" = g ]
then echo "$FILES_AS_ORDERED"
else exit 0
fi |

# Avoid cvs add complaining if it doesn't exist yet:
$DO touch "$BASEFILENAME"
$DO cvs add "$BASEFILENAME"

while read X
do
	# $DO cp -f "$X" "$BASEFILENAME"
	$DO mv -f "$X" "$BASEFILENAME"
	$DO cvs commit -m "$X" "$BASEFILENAME"
	$DO cvs edit "$BASEFILENAME"
	# $DO del "$X"
done

[ "$DO" = echo ] && jshinfo "Call me again with DO=1"

