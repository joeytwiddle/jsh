## Problem: cannot get variables to echo out identically if they have read in binary.
## Flippo suggests solution by encoding to variable-friendly codeset, splitting, and then reverse filtering.  =)

# <flippo> joey_: You don't really want to read a binary file line-by-line, do you?
# <flippo> joey_: It's pretty meaningless
# <flippo> joey_: Some "lines" may be too long for variable to hold
# <joey_> In this case I do, because the binary lines are between txt header lines which I detect.  It's actually a jpeg stream.
# <flippo> oh
# <joey_> flippo, in that case, I guess I should not really do it in sh, but I like to!
# <flippo> you might want to run through a reversible filter then
# <-- Bogaurd has quit ("Bye")
# --> Bogaurd (Bogaurd@ppp137-98.lns1.adl2.internode.on.net) has joined #bash
# <joey_> yes that would be a solution, thanks (do u know any?)
# <flippo> you could use a mime filter, like base64
# <flippo> or quote-printable
# <Bogaurd> if i have a string containing something like 'ppp0:xxxxxxxxx', where each x represents a digit, and there being a random number of digits, how can i cut off the ppp0: part? so that all i have left is the numerical value.
# <flippo> mimencode might do
# --- Thanaporlosuelos is now known as Thanatermesis
# <joey_> flippo, right i will look into them; it would be useful to preserve newlines after filter, but i could always go and detect them... tx!

STREAMFILE="$1"

N=0

# cat "$1" | tee /tmp/tmpfile.tmp |
cat "$1" | pipeboth 2> /tmp/tmpfile.tmp |

while read CONTENT TYPE
do

	[ "$CONTENT" = "Content-type:" ] && [ "$TYPE" = image/jpeg ] || continue

	read EMPTY

	# toline -x "^--ThisRandomString$" > "frame-$N.jpg"

	while read LINE
	do
		[ "$LINE" = "--ThisRandomString" ] && break
		# printf "%s\n" "$LINE"
		# set | grep -A2 "^LINE=" >&2
		# echovar LINE
		tail -n 1 /tmp/tmpfile.tmp
	done > "frame-$N.jpg"

	echo "Written frame-$N.jpg"

	ls -l "frame-$N.jpg"

	N=`expr "$N" + 1`

done
