for X in *; do
	if test -d $X/CVS; then

		cd "$X"

		echo
		echo "Updating $X:"
		cvsupdate

		echo
		echo "Diffing $X:"
		cvsdiff

		# echo
		# echo "Committing $X:"
		# cvscommit

		cd ..

	fi
done

