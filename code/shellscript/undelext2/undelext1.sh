if test "x$1" = "x"; then
	echo "undel1 <filesystem>"
	echo "provides recent inode deletions from filesystem."
	echo "You can look at the size, deletion time, and owner number of the deleted files.  Select the relevant lines and pass as a file to undelext2."
	exit 1
fi
echo lsdel | debugfs $1
