## Oops leaves a 0 length file
TMPF=`jgettmp striphtml`.html
cat "$@" > "$TMPF"
lynx -dump "$TMPF"
jdeltmp "$TMPF"
exit

#################################################

# P_L not working!!
PRESERVE_LINKS=
if test "$1" = "-keeplinks"; then
	PRESERVE_LINKS="[^Aa]";
fi

sed 's+&quot;+"+g' |
sed 's+^[	 ]*++' |
tr "\n" " " |
# Too greedy!
# sed 's+<!--.*-->++g' |
sed 's+<\(BR\|br\|DT\|dt\)[^>]*>+\
+g' |

## WE HAVE PROBLEMS EVEN BEFORE HERE!

test "$PRESERVE_LINKS" || (
	sed 's+<\(A\|a\)[^>]*>+'`curseblue;cursebold`'+g' |
	sed 's+</\(A\|a\)[^>]*>+'`cursenorm`'+g'
) |

sed 's+<\(H\|h\).[^>]*>+\
+g' |
sed 's+</\(H\|h\).[^>]*>+\
+g' |
tr -s "\n" |
sed 's+<\(p\|P\)[^>]*>+\
\
+g' |
sed 's+</\(BLOCKQUOTE\|blockquote\)[^>]*>+\
\
+g' |

sed "s+<$PRESERVE_LINKS[^>]*>++g" |

sed '
	s+&gt;+>+g
	s+&lt;+<+g
	s+&nbsp;+ +g
' |
sed 's+^[	 ]*++' |
sed "
	s+&#149;+ - +g
	s+&#146;+'+g
"
