# "ls" -l $@ | awk ' { printf($9"symlnk"$11"\n"); } '
"ls" -l $@ | awk ' { printf($11"\n"); } '

