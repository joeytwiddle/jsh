if test "x$*" = "x"; then
  more $JPATH/doc.txt
else
	find $JPATH/code/shellscript -name "$*" -o -name "$*.*" | grep -v "CVS"
  cd $JPATH/tools
  echo "### "`justlinks "$*"`":"
  more $*
fi
