if test "x$JWHICHOS" = "xlinux"; then
  test -e "$@"
else
	exists "$@"
fi
