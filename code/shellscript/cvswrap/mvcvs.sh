## BUG: Now allows you rename files, but if there are multiple srcs it should check that dest is a dir!
## TODO: ability to move whole directories (we could perform build a new tree and mvcvs every file)

# safe until you | sh

## Oops
# if test ! "$3" = ""
# then
	# echo "mvcvs <file> <dest-dir/file>"
	# echo "  TODO: deal with more than one file at a time"
	# echo "        allow move directories...mmm"
	# exit 1
# fi

## Function to move one file
mvcvs1() {

	LOCALSRC="$1"
	FILEPATH=`filepath "$LOCALSRC"`
	FILENAME=`filename "$LOCALSRC"`

	LOCALDEST="$2"
	if test -d "$LOCALDEST"
	then
		LOCALDESTDIR="$LOCALDEST"
		DESTFILENAME="$FILENAME" ## ****************
	else
		LOCALDESTDIR=`filepath "$LOCALDEST"`
		DESTFILENAME=`filename "$LOCALDEST"`
	fi

	REPOSFILEDIR=`cat "$FILEPATH/CVS/Repository"`
	REPOSDESTDIR=`cat "$LOCALDESTDIR/CVS/Repository"`

	# Last line doesn't work if LOCALDESTDIR not in cvsroot repository!

	echo "# $REPOSFILEDIR/$FILENAME -> $REPOSDESTDIR"

	CVSFILE="$CVSROOT/$REPOSFILEDIR/$FILENAME,v"
	CVSDESTDIR="$CVSROOT/$REPOSDESTDIR"

	## Checking ok:
	if test ! -d "$FILEPATH"; then
	  echo "Probleming resolving local directory.  Got \"$FILEPATH\""
	  exit 1
	fi
	if test ! -d "$CVSDESTDIR"; then
	  echo "CVS destination \"$CVSROOT\" is not a directory."
	  exit 1
	fi
	if test ! -f "$LOCALSRC"; then
	  echo "\"$LOCALSRC\" is not a file!"
	  exit 1
	fi
	if test ! -f "$CVSFILE"; then
	  echo "cvs file \"$CVSFILE\" does not exist!"
	  exit 1
	fi

	# echo "mv \"$LOCALSRC\" \"$LOCALDESTDIR/\""
	if test ! -d "$CVSDESTDIR"; then
	  echo "mkdir -p \"$CVSDESTDIR\""
	fi
	## We can copy the file in the CVS repository to create the new entry
	echo "cp \"$CVSFILE\" \"$CVSDESTDIR/$DESTFILENAME,v\""
	## I think somebody has to do this (and commit it, although nobody has to add mmm)
	echo "del -cvs \"$LOCALSRC\""

}

## Collect arguments
FILELIST=""
while test ! "$2" = ""
do
	FILELIST="$FILELIST$1
"
	shift
done
LOCALDEST="$1"

## Show move for each file
printf "%s" "$FILELIST" |
while read FILE
do
	mvcvs1 "$FILE" "$LOCALDEST"
done

## Move to top of repository
REPOSPWDDIR=`cat "CVS/Repository"`
printf "$REPOSPWDDIR" | sed 's+/+\
+g' |
while read X
do
	echo "cd .."
done

## Finalise changes
echo "cvsupdate -AdP"
echo "cvscommit"

# FILE="$1"
# DESTDIR="$2"
# FNAME=`filename "$FILE"`
# if test -d "$DESTDIR"; then
  # TOADD="$DESTDIR/$FNAME"
# else
  # TOADD="$DESTDIR"
# fi
# 
# echo "cp \"$FILE\" \"$DESTDIR\""
# # cp "$FILE" "$DESTDIR"
# echo "del \"$FILE\""
# # del "$FILE"
# echo "cvs add \"$TOADD\""
# # cvs add "$TOADD"
# 
# echo "Warning: if your dest is a file, as opposed to a directory, it may not be added correctly."
