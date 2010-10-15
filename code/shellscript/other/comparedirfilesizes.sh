#!/bin/sh
# echo "Use comparedirsfilesize instead?"
# This one does not recurse into directories, but will show if subdirectory size is different
(
cd $1
"ls" -l | awk ' { printf($5" "$9"\n") } ' > $JPATH/tmp.cdfs1.txt
)
(
cd $2
"ls" -l | awk ' { printf($5" "$9"\n") } ' > $JPATH/tmp.cdfs2.txt
)
jfc $JPATH/tmp.cdfs1.txt $JPATH/tmp.cdfs2.txt
# echo "COMMON:"
# jfc common $JPATH/tmp.cdfs1.txt $JPATH/tmp.cdfs2.txt
