# This should not be called cvsdiff, because it ain't like cvs diff:
# it only finds what's missing, not what's been changed.

# echo '# Reasons for failing update:'
# echo '# cvs update 2>/dev/null | grep -v "^\? "'
# echo '# Files which are not the same as the repository versions.'
# echo '# or cvs status 2>/dev/null | grep "^File: " | grep -v "Status: Up-to-date"'
# echo "# Rats, for some reason this doesn't work recursively."

# echo "# Try cvsdiff .* * to see which local files do not exist in repository."
# echo "# Sorry subdirs' files don't work 'cos status loses path."

# TODO: when a new file (not yet in repos) is found, if the dir is also new, the dir should be "cvs add"ed too.

CHECKALL=
if test "$1" = "-all"; then
	CHECKALL=true
	shift
fi

PRE=`cat CVS/Root | afterlast ":"`"/"`cat CVS/Repository`"/"

echo "Status of files compared to repository:"

cvs -q status | egrep "(^File:|Repository revision:)" |
	# sed "s+File:[	 ]*\(.*\)[	 ]*Status:[	 ]*\(.*\)+\1:\2+" |
	sed "s+.*Status:[	 ]*\(.*\)+\1+" |
	sed "s+[	 ]*Repository revision:[^/]*$PRE\(.*\),v+\1+" |
	while read X; do read Y;
		echo "$Y	# $X"
		echo "./$Y" >> /dev/stderr
	done 2> /tmp/in-repos.txt |
	grep -v "Up-to-date"

if test $CHECKALL; then
	echo
	echo "Local files not in repository:"

	find . -type f | grep -iv "/CVS/" > /tmp/local.txt
	jfc nolines /tmp/local.txt /tmp/in-repos.txt |
		sed "s+^./+cvs add ./+"
fi

exit 0

# Good but slow

MAXDEPTH="-maxdepth 1"
if test "$1" = "-r"; then
	MAXDEPTH=""
fi

echo "# "`cursemagenta`"Directories"`cursegrey`":"
find . -type d $MAXDEPTH | grep -v "/CVS/" | grep -v "/CVS$" |
	while read DIR; do
		cvs status "$DIR" 2>/dev/null > /dev/null
		if test ! "$?" = 0; then
			# echo "# "`curseyellow`"Adding unknown directory $DIR/"`cursegrey`
			echo "cvs add $DIR"
		fi
	done

find . -type f $MAXDEPTH | grep -v "/CVS/" |
while read FILE; do
	cvs status "$FILE" 2>/dev/null |
	grep "Status: " | sed "s/File: \([^ 	]*\).*Status: \(.*\)/\2/" |
	while read STATUS; do
		if test ! "$STATUS" = "Up-to-date"; then
			if test "$STATUS" = "Unknown"; then
				ACTION="add"
			else
				ACTION="commit"
			fi
			# echo "# "`curseyellow`"$ACTION""ing $FILE because "`cursemagenta`"$STATUS"`cursegrey`
			echo "# "`cursemagenta`"$STATUS"`cursegrey`
			echo "cvs $ACTION \"$FILE\""
		fi
	done
done

exit 0

curseyellow
echo "OLDER VERSION **********************"
cursegrey

SHABLE=
if test "$1" = "-nocol"; then
	SHABLE=true
	shift
fi

cvs status "$@" 2>/dev/null | grep "^File: " | grep -v "Status: Up-to-date" |
	sed "s/^File: //;s/Status: /\\
/" | while read X; do
		read Y;
		# echo "$X $Y"
		if test $SHABLE; then
			PF="$X"
		else
			PF=`ls -artFd --color "$X" | tr -d "\n"`
		fi
		echo "cvs add \"$X\" 	# $Y: $PF"
	done


# echo "Now find local files which are not even in the repository:"

# ARGS="$@";
# if test "$ARGS" = ""; then
	# ARGS=`find . -type f | grep -v "/CVS/"`
# fi

# Godammit!

# cvs status $ARGS 2>/dev/null | grep "^File:" | grep -v "Status: Up-to-date" |
	# sed "s/^File: //;s/Status: /\\
# /" | while read X; do
		# read Y;
		# echo "$X $Y"
		# if test $SHABLE; then
			# PF="$X"
		# else
			# PF=`ls -artFd --color "$X" | tr -d "\n"`
		# fi
		# echo "cvs add \"$X\" 	# $Y: $PF"
	# done

# Oh dear this does recursion, but the path is lost!

# cvs status $ARGS 2>/dev/null | grep "^File:" | grep -v "Status: Up-to-date" |
	# sed "s/^File: //;s/Status: /\\
# /" | while read X; do
		# read Y;
		# echo "$X $Y"
		# if test $SHABLE; then
			# PF="$X"
		# else
			# PF=`ls -artFd --color "$X" | tr -d "\n"`
		# fi
		# echo "cvs add \"$X\" 	# $Y: $PF"
	# done

# cvs status $ARGS 2>&1 | grep -v "^cvs status: Examining " | grep "^\? " |
	# while read Q X; do
		# printf "cvs add "
		# if test $SHABLE; then
			# echo "$X"
		# else
			# ls -d -F --color "$X"
		# fi
	# done
# 

exit 0



# Old version

# not sure why #!/bin/zsh

# Searches current cvs directory and looks for directories and files
# which have not yet been added to the _local_ repository.

# To highlight lines from cvs diff -c :
# cvs diff -r 1.27 simgen.c | sed "s/^\!/"`curseyellow`"\!/;s/$/"`cursegrey`"/"
# (need to do > and < too)

REPOS="$CVSROOT/"`cat CVS/Repository`

COUNTFILES=0
COUNTDIRS=0
MISSINGDIRS=0
MISSINGFILES=0

find . | grep -v "/CVS" |
  while read SOMETHING; do
    if test -d "$SOMETHING"; then
      DIR="$SOMETHING"
      COUNTDIRS=`expr $COUNTDIRS + 1`
      # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      if test ! -d "$REPOS/$DIR"; then
        echo 'cvs add "'$DIR'" # dir'
        MISSINGDIRS=`expr $MISSINGDIRS + 1`
      fi
    else
      FILE="$SOMETHING"
      COUNTFILES=`expr $COUNTFILES + 1`
      CVSFILE="$REPOS/$FILE,v"
      if test ! -f "$CVSFILE"; then
        MISSINGFILES=`expr $MISSINGFILES + 1`
        echo 'cvs add "'$FILE'"'
      fi
    fi
  done

# find . -type d | grep -v "/CVS" |
  # while read DIR; do
    # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      # echo 'cvs add "'$DIR'"'
    # fi
  # done
# 
# find . -type f | grep -v "/CVS/" |
  # while read FILE; do
    # COUNTFILES=`expr $COUNTFILES + 1`
    # CVSFILE="$CVSROOT/$CHKOUT/$FILE,v"
    # if test ! -f "$CVSFILE"; then
      # MISSINGFILES=`expr $MISSINGFILES + 1`
      # if test $DOADD; then
        # echo 'cvs add "'$FILE'"'
      # else
        # echo "$FILE"
      # fi
    # fi
  # done

echo "# $MISSINGFILES / $COUNTFILES files missing, $MISSINGDIRS / $COUNTDIRS directories." >&2
