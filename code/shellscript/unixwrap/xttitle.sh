# Only runs xttitle if it is present
if jwhich xttitle 2>&1 > /dev/null; then
	`jwhich xttitle` "$@"
fi
