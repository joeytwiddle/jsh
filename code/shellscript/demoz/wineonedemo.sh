xset fp- unix/:7101 2>/dev/null

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
	echo "==== RUNNING $X ===="
	echo
	cursenorm

	# To test for gl/non-gl progs:
	# -dll opengl32=s,n 
	# --managed 
	# --desktop 640x480+0+0 
	# export WINEPREFIX=$HOME/.wine_fake
	wine "$X"

	sleep 1

	## This is safer but the killall below should be used for certainty!
	mykill -x "wine $X"

	curseyellow
	echo
	echo "==== KILLING WINE ===="
	echo
	cursenorm

	curseblue
	# (
		# killall wine.bin
		# killall wineserver
		rm -rf $HOME/.wine/wineserver-*
	# ) > /dev/null
	# Check it has been killed!
	sleep 1
	findjob wine |
	grep -v "$JPATH/tools/" |
	grep -v "winealldemoz" |
	grep -v "wineonedemo"
	cursenorm

	sleep 10
	waitforkeypress

done

