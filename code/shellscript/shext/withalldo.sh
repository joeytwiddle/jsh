## TODO: goes slow on long lists, presumably because of the long string manipulation.  Fix by using a stream | sh, so we can echo straight to stream instead of adding to String.

## One day we are going to hit too-many-arguments, and we'll need to get withalldo to do it it chunks.  But that would change functionality :-/

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
