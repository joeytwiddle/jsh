FOUND=`find $1 -newer $2 -maxdepth 0`
if test "$FOUND" = ""; then
  # echo "no $1 older than $2"
  exit 1
fi
# echo "yes $1 newer than $2"
exit 0
