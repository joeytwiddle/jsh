#!/bin/sh
if test "$JM_UNAME" = "linux"; then
  test -e "$1"
else
	exists "$1"
fi
