#!/bin/sh
cvs -z 9 -q update "$@" |
	grep -v "^\? " ## BUG: returns non-zero exit code, if the update had nothing to output
# cvs update "$@" 2>&1 |
	# grep -v "^? " |
	# grep -v "^cvs update: Updating " |
	# grep -v "^cvs server: Updating "

## BUG: With args "-AdP <dir>" cvsedit doesn't target the target dir, but cwd!
cvsedit "$@"

