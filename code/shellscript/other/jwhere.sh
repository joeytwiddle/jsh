if jwhich whereis quietly; then
  WHERE=`jwhich whereis`
# elif jwhich whereis quietly; then
#   WHERE=`jwhich whereis`
else
  WHERE="which" # shell builtin
  # WHERE="where" # shell builtin, no joy on Solaris
  # echo "jwhere.sh: jwhich could not find where or whereis"
  # exit 1
fi
$WHERE $@
