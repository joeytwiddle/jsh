sed 's+&quot;+"+g' |
sed 's+^[	 ]*++' |
tr "\n" " " |
# Too greedy!
# sed 's+<!--.*-->++g' |
sed 's+<\(BR\|br\)[^>]*>+\
+g' |
sed 's+<\(p\|P\)[^>]*>+\
\
+g' |
sed 's+<\(A\|a\)[^>]*>+'`curseblue;cursebold`'+g' |
sed 's+</\(A\|a\)[^>]*>+'`cursegrey`'+g' |
sed 's+<[^>]*>++g' |
sed 's+&gt;+>+g;s+&lt;+<+g;s+&nbsp;+ +g' |
sed 's+^[	 ]*++' # |
# more
# X=`jgettmp`
# cat > $X
# lynx -dump $X
# jdeltmp $X
