## Equivalent to:
# tr "\n" "\000" | xargs -0 "$@"

COM=""

for ARG
## Maybe better for backwards compatability:
# for ARG; in "$@"
do
	COM="$COM\"$ARG\" "
done

while read LINE
do
	COM="$COM\"$LINE\" "
done

eval "$COM"
