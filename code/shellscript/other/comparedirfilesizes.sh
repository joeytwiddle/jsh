"ls" -l $1 | awk ' { printf($5" "$9"\n") } ' > $JPATH/tmp.cdfs1.txt
"ls" -l $2 | awk ' { printf($5" "$9"\n") } ' > $JPATH/tmp.cdfs2.txt
jfc $JPATH/tmp.cdfs1.txt $JPATH/tmp.cdfs2.txt
jfc common $JPATH/tmp.cdfs1.txt $JPATH/tmp.cdfs2.txt