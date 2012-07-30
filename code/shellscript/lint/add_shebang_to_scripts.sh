#!/bin/sh
find . -type f -name "*.sh" | grep -v /CVS/ |
while read f
do
	if ! head -n 1 "$f" | grep '^#!/'
	then
		(
			echo '#!/bin/sh'
			cat "$f"
		) | dog "$f"
	fi
done
