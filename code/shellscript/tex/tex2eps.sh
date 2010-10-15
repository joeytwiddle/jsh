#!/bin/sh
# Oh dear apparently this outputs a raster!

if test "$1" = "" || test "$2" = ""; then
echo "tex2eps <input-tex-file-head>"
echo "  or"
echo "tex2eps <input-tex> <eps-file-head>"
exit 1
fi

INPUT="$1"
shift

if test "$1" = ""; then
	OUTPUT="$INPUT.eps"
else
	cat > "tmp.tex" << !
\\documentclass[12pt]{article}
\\pagestyle{empty}
\\begin{document}
$INPUT
\\end{document}
!
	INPUT="tmp"
	OUTPUT="$1.eps"
	shift
fi

latex "$INPUT.tex"
dvips -E "$INPUT.dvi" -o "$OUTPUT"
rm *.log *.aux "$INPUT.dvi"
