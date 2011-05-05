#!/bin/sh
dev="$1"
if [ ! -e "$dev" ]
then echo "device '$dev' does not exist!" ; exit 1
fi
undelext1 "$dev" | tee undelext1.visible_deletions | tail -n 14 | undelext2 - /tmp/recovered.$$ | debugfs "$dev"

for f in /tmp/recovered.$$/undel-[0-9]*
do
	ext=`file "$f" | tr -s ' ' | cut -d ' ' -f 2`
	echo mv "$f" "$f"."$ext"
done

