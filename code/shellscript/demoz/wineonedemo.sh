curseyellow
echo
echo "==== UNZIPPING $1 ===="
echo
cursenorm

rm -rf /tmp/demotmp
mkdir -p /tmp/demotmp
cd /tmp/demotmp

unzip "$1"

echo
ls
echo

find . -name "*.exe" -or -name "*.EXE" |
while read X; do

	curseyellow
	echo
	echo "==== KILLING WINE ===="
	echo
	cursenorm

	(
	curseblue
		killall wine.bin
		killall wineserver
		rm -rf $HOME/.wine/wineserver-*
	cursenorm
	) > /dev/null
	# Check it has been killed!
	# sleep 1
	# findjob wine |
	# grep -v "$JPATH/tools/" |
	# grep -v "winealldemoz" |
	# grep -v "wineonedemo"

	curseyellow
	echo
	echo "==== RUNNING $X ===="
	echo
	cursenorm

	# To test for gl/non-gl progs:
	# -dll opengl32=s,n 
	# --managed 
	# --desktop 640x480+0+0 
	wine "$X"

	sleep 1

done

