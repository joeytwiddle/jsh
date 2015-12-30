#!/bin/sh

for file
do
	# BUG: Sometimes produces %age > 100%, because as 'du' says "apparent size is usually smaller".
	#      Common on text files, but also seen on small image files.

	total_size=$(du --apparent-size -B1 "$file" | sed 's+\s.*++')
	#total_size=$(stat -c "%s" "$file")
	data_size=$(du -B1 "$file" | sed 's+\s.*++')

	percentage_full=$(expr "$data_size" '*' 100 / "$total_size")

	printf "%s is %s%% full\n" "$file" "$percentage_full"
done
