for X in "$@"; do
	cp "$X" "$X".b4jind
	if endswith "$X" "\.htm" || endswith "$X" "\.html"; then
		# hindent -s -t 1 -i 1 "$X" | trimempty > tmp.txt
		hindent -t 1 -i 1 "$X" | sed "s+^[	 ]*$++" > tmp.txt
		cp tmp.txt "$X"
	else
		# indent -sob -br -npsl -ce -brs $X
		astyle --indent=spaces=2 $X
	fi
done
