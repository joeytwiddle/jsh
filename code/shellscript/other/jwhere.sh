if jwhich whereis quietly; then
  WHERE=`jwhich whereis`
# elif jwhich whereis quietly; then
#   WHERE=`jwhich whereis`
else
  WHERE="where" # shell builtin
  # echo "jwhere.sh: jwhich could not find where or whereis"
  # exit 1
fi
$WHERE $@