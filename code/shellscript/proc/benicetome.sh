if test "x$@" = "x"; then
  echo "benicetome \$\$"
  exit 1
fi

PID="$@"
requestsudo "source $JPATH/startj
myrenice -15 '$PID'"
