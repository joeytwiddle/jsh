if test "x$1" = "x"; then
  echo "benicetome \$\$"
  exit 1
fi

PID="$1"
requestsudo "source $JPATH/startj
myrenice -15 '$PID'"
