#!/bin/sh
## Note formatting: % must be %%, ...
# ## Only runs the official xttitle if it is present
# ## Under Unix I had to put 2>&1 last.
# if jwhich xttitle > /dev/null 2>&1; then
	# `jwhich xttitle` "$@"
# else
	## printf has problems with the % in:
	##   grep "#dpkg-buildpackage" debuild.out | after "\% "
	## solved by using %s of course!
	X="$*"
	# printf "]0;$X"
	# echo -n "]0;$X"
	# echo "]0;$X" | tr -d "\n"
	printf "]0;%s" "$X" | tr '\n' '\\'
# fi
