#!/bin/sh

# Some solutions drawn from: http://unix.stackexchange.com/questions/86442/finding-sparse-files

# A quick way to search.  We could adjust sed to show the percentages.
# I suspect this suffers from the same BUG outlined below.
#find "$@" -type f ! -size 0 -printf '%S:%p\0' | sed -zn 's/^0[^:]*://p' | tr '\0' '\n'

for file
do
	# BUG: Sometimes produces %age > 100%, because as 'du' says "apparent size is usually smaller".
	#      Common on text files, but also seen on small image files.

	total_size=$(du --apparent-size -B1 "$file" | sed 's+\s.*++')
	#total_size=$(stat -c "%s" "$file")
	data_size=$(du -B1 "$file" | sed 's+\s.*++')

	# Avoid division by zero errors
	if [ "$total_size" = 0 ]
	then
		echo "$file is empty"
		continue
	fi

	percentage_full=$(expr "$data_size" '*' 100 / "$total_size")

	printf "%s is %s%% full\n" "$file" "$percentage_full"

	# Another way to check is:
	#if perl -le 'seek STDIN,0,4;$p=tell STDIN; seek STDIN,0,2; exit 1 if $p == tell STDIN' < "$file"
	#then printf "%s\n" "$file is sparse"
	#else printf "%s\n" "$file is not sparse"
	#fi
done
