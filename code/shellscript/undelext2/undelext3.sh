#!/bin/sh
dev="$1"
if [ ! -e "$dev" ]
then
cat << !
device '$dev' does not exist!

undelext3 <dev>
  recovers the 10 most recently deleted files on that ext2 partition
  works on ext2 NOT on ext3!

!
fi
undelext1 "$dev" | tee undelext1.visible_deletions | tail -n 14 | undelext2 - /tmp/recovered.$$ | debugfs "$dev"

for f in /tmp/recovered.$$/undel-[0-9]*
do
	ext=`file "$f" | tr -s ' ' | cut -d ' ' -f 2`
	echo mv "$f" "$f"."$ext"
done

