## Not equivalent to:
# tr "\n" "\000" | xargs -0 "$@"

while read LINE
do
	"$@" "$LINE"
done
