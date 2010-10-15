#!/bin/sh
cd /

if test "$1" = -all
then
  'ls' /var/lib/dpkg/info/*.md5sums |
  sed "s+/var/lib/dpkg/info/++;s+\.md5sums++"
else
  echo "$@"
fi |

while read PKG
do
  cursecyan
  echo "$PKG"
  cursenorm
  (
    cat /var/lib/dpkg/info/$PKG.md5sums |
    while read CKSUM FILENAME
    do
      echo "Summing $FILENAME" >&2
      md5sum "$FILENAME"
    done > /tmp/last.md5sum
    jfcsh "/var/lib/dpkg/info/$PKG.md5sums" "/tmp/last.md5sum"
  ) > /tmp/$PKG.cksumdiff
done
