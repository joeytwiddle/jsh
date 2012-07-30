# echo '1024 * '"$(equery size "$1" | tail -n 1 | takecols 4)" | bc
# echo '1024 * '"$(equery size "$1" | afterfirst "size(" | beforefirst ")")" | bc
for PKG
do
	[[ "$PKG" = "$*" ]] || echo -e -n "$PKG:\t"
	equery size "$PKG" | afterfirst "size(" | beforefirst ")"
done

