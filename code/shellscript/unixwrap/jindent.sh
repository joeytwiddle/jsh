for X in "$@"; do
	cp $X $X.b4ind
	# indent -sob -br -npsl -ce -brs $X
	astyle --indent=spaces=2 $X
done
