echo "Note: these may be hard links,"
echo "or possibly (to check) symlinks, so don't delete the target!"
echo

# find . -type f |
# while read X; do
  # 'ls' -l "$X" | takecols 5 9 10 11 12 13 14 15 16 17
# done |
# keepduplicatelines -gap 1

find . -type f |
while read X; do
  'ls' -l "$X" | takecols 5 9 10 11 12 13 14 15 16 17
done |
keepduplicatelines 1 |
takecols 2 3 4 5 6 7 8 9 10 |

while read X; do
  cksum "$X"
done |
keepduplicatelines -gap 1 2

# find . -type f |
# while read X; do
  # cksum "$X"
# done |
# keepduplicatelines -gap 1 2

# CKSUMS=`find . -type f | while read X; do
    # cksum "$X"
  # done`
# 
# FINDDUPS=`echo "$CKSUMS" | keepduplicatelines 1 2`
# 
# echo "$FINDDUPS" | while read X; do
  # echo "$CKSUMS" | grep "^$X"
  # echo
# done
