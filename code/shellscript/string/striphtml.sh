sed 's+&quot;+"+g' |
sed 's+^[	 ]*++' |
tr "\n" " " |
# Too greedy!
# sed 's+<!--.*-->++g' |
sed 's+<\(BR\|br\)[^>]*>+\
+g' |
sed 's+<\(A\|a\)[^>]*>+'`curseblue;cursebold`'+g' |
sed 's+</\(A\|a\)[^>]*>+'`cursenorm`'+g' |
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
sed 's+<[^>]*>++g' |
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
