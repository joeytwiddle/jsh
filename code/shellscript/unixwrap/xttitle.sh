#!/bin/sh
printf "]0;$*"
# # Only runs the official xttitle if it is present
# # Under Unix I had to put 2>&1 last.
# if jwhich xttitle > /dev/null 2>&1; then
	# `jwhich xttitle` "$@"
# fi
