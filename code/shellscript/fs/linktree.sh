## Unlike linkhome (and stow)
SOURCE="$1"
DEST="$2"

[ "$DEST" ] || DEST=.

( cd "$SOURCE" && find . -type d ) |
while read DIR
do mkdir "$DEST"/"$DIR" || exit
done

( cd "$SOURCE" && find . -not -type d ) |
while read FILE
do ln -s "$SOURCE"/"$FILE" "$DEST"/"$FILE" || exit
done
