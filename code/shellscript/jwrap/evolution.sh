## My evolution and eclipse look much nicer once my gnome fonts have been loaded:
gnome-font-properties & PID=$! ; ( sleep 20s ; kill $PID ) &

echo "Making quick backup of evolution config..."

BACKUPFILE="$HOME/evolution-config-bak.tgz"
MARKERFILE="$HOME/evolution-config-bak-ok.marker"

if test ! -f "$MARKERFILE"
then echo "If you want me to keep rotated backups of your evolution config, touch $MARKERFILE"
else

	test -f "$BACKUPFILE" &&
		mv "$BACKUPFILE" "$HOME/evolution-config-bak-previous.tgz"

	cd "$HOME/evolution"
	FILES=`'ls' | grep -v ^local | grep -v ^mail`
	tar cfz "$BACKUPFILE" $FILES
	rotate -nozip -max 4 "$BACKUPFILE"

fi

echo "Starting evolution..."

`jwhich evolution` "$@"
