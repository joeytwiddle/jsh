# jsh-depends-ignore: wine winealldemoz
# jsh-depends: mykill waitforkeypress findjob curseblue curseyellow cursenorm
# jsh-ext-depends: find wine unzip

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

## Didn't really work (so should at least randomorder them!)
## Probably something was stealing and eating stdin!
## Ahhhh, the waitforkeypress!  TURNED OFF
## Oh, and probably the WineDbg console if it appears.  SOLVED WITH yes q
find . -iname "*.exe" | randomorder |
while read EXECUTABLE_FILE
do

## Of course this one doesn't like .exe's with spaces in their name:
# for EXECUTABLE_FILE in `find . -iname "*.exe"`
# do

	curseyellow
	echo
	echo "==== KILLING WINE ===="
	echo
	cursenorm

	## This is safer but the killall below should be used for certainty!
	echo | mykill -x "wine $EXECUTABLE_FILE"

	curseblue
	# (
		killall wine.bin wineserver wine-preloader
		rm -rf $HOME/.wine/wineserver-*
	# ) > /dev/null
	# Check it has been killed!
	sleep 1
	findjob wine |
	grep -v "$JPATH/tools/" |
	grep -v "winealldemoz" |
	grep -v "wineonedemo"
	cursenorm

	sleep 2



	curseyellow
	echo
	echo "==== RUNNING $EXECUTABLE_FILE ===="
	echo
	cursenorm

	# To test for gl/non-gl progs:
	# -dll opengl32=s,n 
	# --managed 
	# --desktop 640x480+0+0 
	# export WINEPREFIX=$HOME/.wine_fake

	yes q | ## This quits the WineDbg console if it starts.

	# vsound -v -f /tmp/vsound.out.wav -d -t \
	# /usr/bin/wine "$EXECUTABLE_FILE"
	wine "$EXECUTABLE_FILE"

	sleep 1

	# sleep 10
	# waitforkeypress

done

