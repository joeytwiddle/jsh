# ls $1/. > firstdir
# ls $2/. > seconddir

ADATA=`jgettmp firstdir`
BDATA=`jgettmp seconddir`

(
  cd "$1"
  find . -type f |
    while read X; do
      'ls' -l "$X" | takecols 5 9 10 11 12 13 14 15 16
    done
) > "$ADATA"

(
  cd "$2"
  find . -type f |
    while read X; do
      'ls' -l "$X" | takecols 5 9 10 11 12 13 14 15 16
    done
) > "$BDATA"

jfc "$ADATA" "$BDATA"

jdeltmp "$ADATA" "$BDATA"

# ( cd "$1"
  # du -ab
# # find . -type f | while read X; do
  # # echo "$X"
  # # filesize "$X"
# # done
# ) > firstdir.sz

# ( cd "$2" # Must be absolute!
  # du -ab
# # for X in `find . -type f`; do
# # find . -type f | while read X; do
# #   filesize "$X"
# # done
# ) > seconddir.sz
# 
# jfc firstdir.sz seconddir.sz
