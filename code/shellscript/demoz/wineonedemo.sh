curseyellow
echo
echo "==== UNZIPPING $1 ===="
echo
cursegrey

rm -rf /tmp/demotmp
mkdir -p /tmp/demotmp
cd /tmp/demotmp

unzip "$1"

echo
ls
echo

ls *.exe *.EXE |
while read X; do

	curseyellow
	echo
	echo "==== KILLING WINE ===="
	echo
	cursegrey

	sleep 2
	curseblue
	(
		killall wine.bin
		killall wineserver
		del $HOME/.wine/wineserver-*
	)
	cursegrey
	sleep 1
	findjob wine | grep -v "\.sh"
	sleep 1

	curseyellow
	echo
	echo "==== RUNNING $X ===="
	echo
	cursegrey

	wine "$X"

done

