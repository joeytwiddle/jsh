if test "$*" = ""; then
  echo "jdoc <command>"
	echo "  will show you the contents of $JPATH/tools/<command>"
	echo "  if you are lucky there might be some documentation in comments"
else
	# find $JPATH/code/shellscript -name "$*" -o -name "$*.*" | grep -v "CVS"
  cd $JPATH/tools
  # echo "### "`justlinks "$*"`":"
  # echo "::::::::::::::"
	# echo `justlinks "$*"`
  # echo "::::::::::::::"
  # more $*
  ( echo "::::::::::::::"
	  # echo "$1 -> "`justlinks "$*"`
	  echo `justlinks "$*"`
	  echo "::::::::::::::"
	  cat $*
	) | more
fi
