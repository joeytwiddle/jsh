if test "$RANDOM"; then
	echo "$RANDOM"
else
	# Not on Maxx: echo "" | awk ' BEGIN { printf( int(100001*rand()) ); printf("\n"); } '
	# Um!
	echo $$
fi
