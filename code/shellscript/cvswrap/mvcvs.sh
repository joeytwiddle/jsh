## BUG: Now allows you rename files, but if there are multiple srcs it should check that dest is a dir!
## NEW: "Prototyped" ability to move whole directories (we could perform build a new tree and mvcvs every file)

echo "## If the following looks ok to you, run mvcvs again with | sh -e -x"

echo "## TODO: check the file has been committed, otherwise it doesn't work!!!" >&2

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

	## Last line doesn't work if LOCALDESTDIR not in cvsroot repository!
	if test ! "$REPOSDESTDIR"
	then echo "$LOCALDESTDIR is not a cvs directory; aborting."; exit 1
	fi

	echo "## $REPOSFILEDIR/$FILENAME -> $REPOSDESTDIR"

	CVSDESTDIR="$CVSROOT/$REPOSDESTDIR"

	## Checking ok:
	if test ! -d "$FILEPATH"; then
		echo "Probleming resolving local directory.  Got \"$FILEPATH\""
		exit 1
	fi
	if test ! -d "$CVSDESTDIR"; then
		## I don't think we should mkdir this ourselves.  Dunno: consider.
		echo "CVS destination \"$CVSROOT\" is not a directory."
		exit 1
	fi

	if test -d "$LOCALSRC"
	then

		if test "$FILENAME" = CVS
		then echo "## Skipping cvs directory: $LOCALSRC"; break
		fi

		## Moving a directory:

		echo "TODO: Create new directory tree, and add to CVS"
		echo "TODO: mvcvs all the files from current tree to new tree"
		echo "TODO: Remove local src tree and dirs from cvs."
		echo "  or"
		echo "TODO: Copy tree over in cvs."
		echo "TODO: Remove src tree from CVS and local checkout."
		echo "TODO: Update local."
	
	elif test -f "$LOCALSRC"
	then

		## Moving a file:

		CVSFILE="$CVSROOT/$REPOSFILEDIR/$FILENAME,v"
		
		## Checking ok:
		if test ! -f "$CVSFILE"; then
		  echo "cvs file \"$CVSFILE\" does not exist!"
		  exit 1
		fi

		## Unreachable due to above:
		# if test ! -d "$CVSDESTDIR"
		# then echo "mkdir -p \"$CVSDESTDIR\""
		# fi

		## We can copy the file in the CVS repository to create the new entry
		echo "cp \"$CVSFILE\" \"$CVSDESTDIR/$DESTFILENAME,v\""
		## To keep the client in sync, we remove the file and call "cvs remove", which will also remove it from the repository (when we commit later).
		## Could be replaced with: rm -f "$LOCALSRC" ; cvs remove "$LOCALSRC"
		echo "del -cvs \"$LOCALSRC\""

		## Finalise changes
		echo "cvsupdate -AdP"
		echo "cvscommit -m \"MOVED to $LOCALDEST\" $LOCALSRC"
		echo "cvscommit -m \"MOVED from $LOCALSRC\" $LOCALDEST"

	else

		echo "Source \"$LOCALSRC\" is not a file or a directory!"
		exit 1

	fi

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

# ## Move to top of repository
# REPOSPWDDIR=`cat "CVS/Repository"`
# printf "$REPOSPWDDIR" | sed 's+/+\
# +g' |
# while read X
# do
	# echo "cd .."
# done

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
