echo "Making quick backup of evolution config..."

test -f "$HOME/evolution-config-bak.tgz" &&
	mv "$HOME/evolution-config-bak.tgz" "$HOME/evolution-config-bak-previous.tgz"

cd "$HOME/evolution"
FILES=`'ls' | grep -v "local"`
tar cfz "$HOME/evolution-config-bak.tgz" $FILES
rotate -nozip -max 4 "$HOME/evolution-config-bak.tgz"

echo "Starting evolution..."

`jwhich evolution` "$@"
