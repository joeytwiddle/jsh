if test "$JM_UNAME" = "linux"; then
  test -e "$@"
else
	exists "$@"
fi
