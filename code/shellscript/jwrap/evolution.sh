echo "Making quick backup of evolution config..."

test -f "$HOME/evolution-config-bak.tgz" &&
	mv "$HOME/evolution-config-bak.tgz" "$HOME/evolution-config-bak-previous.tgz"

if test -f "$HOME/evolution-config-bak-ok.marker"
then
	cd "$HOME/evolution"
	FILES=`'ls' | grep -v "local"`
	tar cfz "$HOME/evolution-config-bak.tgz" $FILES
	rotate -nozip -max 4 "$HOME/evolution-config-bak.tgz"
else
	echo "If you want me to keep rotated backups of your evolution config, touch $HOME/evolution-config-bak-ok.marker"
fi

echo "Starting evolution..."

`jwhich evolution` "$@"
