if test "x$*" = "x"; then
  more $JPATH/doc.txt
else
	find $JPATH/code/shellscript -name "$*" -o -name "$*.*"
  cd $JPATH/tools
  echo "### "`justlinks "$*"`":"
  more $*
fi
