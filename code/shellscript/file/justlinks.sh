if test "$*" = ""; then
  echo "justlinks <symlinks>"
  echo "  or"
  echo "justlinks -absolute <symlink>"
  exit 1
fi

if test "$1" = "-absolute"; then
  absolutepath `dirname "$2"` `'ls' -ld "$2" | takecols 11`
else
  # "ls" -l $@ | awk ' { printf($9"symlnk"$11"\n"); } '
  # "ls" -l $* | awk ' { printf($11"\n"); } '
  # "ls" -ld $* | awk ' { printf($11"\n"); } '
  'ls' -ld $* | takecols 11
fi

