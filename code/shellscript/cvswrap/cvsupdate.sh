cvs -q update "$@"
# cvs update "$@" 2>&1 |
	# grep -v "^? " |
	# grep -v "^cvs update: Updating " |
	# grep -v "^cvs server: Updating "
