## TODO: allow you to provide a new filename if sending just one
##       ability to move whole directories

# safe until you | sh

## Function to move one file
mvcvs2() {

	LOCALFILE="$1"
	LOCALDESTDIR="$2"

	FILEPATH=`filepath "$LOCALFILE"`
	FILENAME=`filename "$LOCALFILE"`
	REPOSFILEDIR=`cat "$FILEPATH/CVS/Repository"`
	REPOSDESTDIR=`cat "$LOCALDESTDIR/CVS/Repository"`

	# Last line doesn't work if LOCALDESTDIR not in cvsroot repository!

	echo "# $REPOSFILEDIR/$FILENAME -> $REPOSDESTDIR"

	CVSFILE="$CVSROOT/$REPOSFILEDIR/$FILENAME,v"
	CVSDESTDIR="$CVSROOT/$REPOSDESTDIR"

	if test ! -d "$FILEPATH"; then
	  echo "Probleming resolving local directory.  Got \"$FILEPATH\""
	  exit 1
	fi
	if test ! -d "$CVSDESTDIR"; then
	  echo "CVS destination \"$CVSROOT\" is not a directory."
	  exit 1
	fi
	if test ! -f "$LOCALFILE"; then
	  echo "\"$LOCALFILE\" is not a file!"
	  exit 1
	fi
	if test ! -f "$CVSFILE"; then
	  echo "cvs file \"$CVSFILE\" does not exist!"
	  exit 1
	fi

	# echo "mv \"$LOCALFILE\" \"$LOCALDESTDIR/\""
	if test ! -d "$CVSDESTDIR"; then
	  echo "mkdir -p \"$CVSDESTDIR\""
	fi
	## We can copy the file in the CVS repository to create the new entry
	echo "cp \"$CVSFILE\" \"$CVSDESTDIR/\""
	## We must delete the local version.  Is it up-to-date?!
	echo "del -cvs \"$LOCALFILE\""

}

## Collect arguments
FILELIST=""
while test ! "$2" = ""
do
	FILELIST="$FILELIST$1
"
	shift
done
LOCALDESTDIR="$1"

## Show move for each file
printf "%s" "$FILELIST" |
while read FILE
do
	mvcvs2 "$FILE" "$LOCALDESTDIR"
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
