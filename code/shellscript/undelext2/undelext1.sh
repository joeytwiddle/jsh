if test "x$1" = "x"; then
  echo "undel1 <filesystem-device>"
  echo "provides recent inode deletions from filesystem."
  echo "You can look at the size, deletion time, and owner number of the deleted files.  Select the relevant lines and pass as a file to undelext2."
  echo "Note for ext2 undeletion, you need to know when the file was deleted, and since it no longer has a filename, you will have to search for it by known content, and rename it."
  exit 1
fi
echo lsdel | debugfs $1
