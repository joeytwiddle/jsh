if test "x$1" = "x"; then
  echo 'dvi2pdf <src>'
  echo 'dvi2pdf <src>.ps <dest>.pdf'
  exit 1
fi
echo "DVI -> PS"
if test "x$2" = "x"; then
  OUTFILE="$1.pdf"
else
  OUTFILE="$2"
fi
dvips "$1" -f > tmp.ps
echo "PS -> PDF"
ps2pdf tmp.ps "$OUTFILE"
/bin/rm tmp.ps