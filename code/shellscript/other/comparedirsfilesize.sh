# ls $1/. > firstdir
# ls $2/. > seconddir

( cd "$1"
	du -ab
# find . -type f | while read X; do
  # echo "$X"
  # filesize "$X"
# done
) > firstdir.sz

( cd "$2" # Must be absolute!
	du -ab
# for X in `find . -type f`; do
# find . -type f | while read X; do
#   filesize "$X"
# done
) > seconddir.sz

jfc firstdir.sz seconddir.sz
