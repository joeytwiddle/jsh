## Note: very slow

## WARNING (TODO)!! Modifies the original file you pass; nasty

STREAMFILE="$1"

N=0

while true
do

	cat "$1" |
	fromline -x "^Content-type: image\/jpeg$" |
	fromline -x "^$" |
	toline -x "^--ThisRandomString$" > "frame-$N.jpg"

	echo "Written frame-$N.jpg"

	cat "$1" |
	fromline -x "^Content-type: image\/jpeg$" |
	fromline -x "^$" |
	fromline -x "^--ThisRandomString$" |
	dog "$1"

	N=`expr "$N" + 1`

done
