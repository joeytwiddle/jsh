cvs -q update "$@" | grep -v "^\? "
# cvs update "$@" 2>&1 |
	# grep -v "^? " |
	# grep -v "^cvs update: Updating " |
	# grep -v "^cvs server: Updating "
