#!/bin/sh

# TODO: Rename these scripts!  They are for ext2, not for ext1 or ext3.  And move them to 'forensics' folder.
# Remove these scripts.  They are largely useless, since nobody uses ext2 any more, and they fail to recover anything on ext3.

# See also: http://unix.stackexchange.com/questions/320149/read-past-end-of-file-to-recover-data/320150
# That is very inefficient but it supports general purpose recovery on a non-encrypted partition, by searching for a text string:
# strings -n 12 -t d /dev/partition | grep -F 'text snippet'

if test "x$1" = "x"; then
  echo "undel1 <filesystem-device> [ > <file_to_edit> ]"
  echo "provides recent inode deletions from filesystem."
  echo "You can look at the size, deletion time, and owner number of the deleted files.  Select the relevant lines and pass as a file to undelext2."
  echo "Note for ext2 undeletion, you need to know when the file was deleted, and since it no longer has a filename, you will have to search for it by known content, and rename it."
  exit 1
fi
echo lsdel | debugfs $1
