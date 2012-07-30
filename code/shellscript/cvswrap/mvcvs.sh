#!/bin/sh
## BUG TODO: mvcvs only works when recent version of file has been committed
##           otherwise changed checkout file gets deleted (retrievable)
##    SOLVE: check if checkout is committed / up-to-date, and warn if bad situation ; consider making a copy and putting it back after checkout of refactored files/folder

## I think, the best way to move a file or folder in CVS, is to make a duplicate of the old tree in the new position, then do an official cvs remove on the old one, so that all clients can clean it up tidily.

## BUG: Now allows you rename files, but if there are multiple srcs it should check that dest is a dir!
## NEW: "Prototyped" ability to move whole directories (we could perform build a new tree and mvcvs every file)

echo "## If the following looks ok to you, run mvcvs again with | bash -e -x"

echo "## TODO: check the file has been committed, otherwise it doesn't work!!!" >&2
# jshwarn "If your checkout is not in sync, it will be committed and updated!"
jshwarn "Please ensure you have done cvsupdate -AdP first!"

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
		echo "How to move a folder in CVS:"
		# echo "TODO: Create new directory tree, and add to CVS"
		# echo "TODO: mvcvs all the files from current tree to new tree"
		# echo "TODO: Remove local src tree and dirs from cvs."
		# echo "  or"
		echo "TODO: Copy tree over in cvs."
		# echo "TODO: Remove src tree from CVS and local checkout."
		echo "TODO: Update local checkout to the new destination."
		echo "TODO: Delete the source folder from the repository legally."

	elif test -f "$LOCALSRC"
	then

		## Moving a file:

		CVSFILE="$CVSROOT/$REPOSFILEDIR/$FILENAME,v"
		
		## Checking ok:
		if test ! -f "$CVSFILE"; then
		  echo "CVS file \"$CVSFILE\" does not exist!" >&2
		  exit 1
		fi

		## Unreachable due to above:
		# if test ! -d "$CVSDESTDIR"
		# then echo "mkdir -p \"$CVSDESTDIR\""
		# fi

		## We can copy the file in the CVS repository to create the new entry
		echo "set -e -x &&"
		echo "cp \"$CVSFILE\" \"$CVSDESTDIR/$DESTFILENAME,v\" &&"
		# Make a backup in case update or anything later messes with our file:
		echo "cp \"$LOCALSRC\" /tmp/\"$FILENAME\".b4mvcvs &&"
		echo "cvs update -AdP \"$LOCALDEST\" &&"

		## To keep the client in sync, we remove the file and call "cvs remove", which will also remove it from the repository (when we commit later).
		# echo "del -cvs \"$LOCALSRC\" &&" ## does cvs remove, and sends the file to trash
		# echo "del \"$LOCALSRC\" &&"

		## Maybe we should commit the working copy?
		## At the moment we keep the local copy and rename it too.
		echo "mv \"$LOCALSRC\" \"$LOCALSRC.mvcvs\" &&"
		# echo "rm -f \"$LOCALSRC\" &&"

		echo "cvs remove \"$LOCALSRC\" &&"

		## Finalise changes
		# echo "cvsupdate -AdP &&" ## instead we ask user to do it
		echo "cvscommit -m \"MOVED to $LOCALDEST\" \"$LOCALSRC\" &&"
		echo "cvscommit -m \"MOVED from $LOCALSRC\" \"$LOCALDEST\" &&"
		echo "mv -f \"$LOCALSRC.mvcvs\" \"$LOCALDEST\""

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
	if [ -f "$FILE" ]
	then
		mvcvs1 "$FILE" "$LOCALDEST"
	else
		echo 'I do not know how to mvcvs for folders yet!'
		## It would probably involve:
		# Make final check-in.
		# Move working copy somewhere hidden.
		# Move folder in root cvs server folder.
		# Checkout newly positioned folder on client.
		# Remove from hidden working tree any CVS folders.
		# Copy hidden working tree over newly checked-out version.
		# Delete hidden working tree.  (Perhaps last 2 can be combined as move.)
		exit 2
	fi
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
