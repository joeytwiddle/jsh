if test "x$1" = "x"; then
	echo "undel1 <filesystem>"
	echo "provides recent inode deletions from filesystem"
	exit 1
fi
echo lsdel | debugfs $1
