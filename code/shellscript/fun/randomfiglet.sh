## Stolen from Hwi's front page script.

if [ "$1" = -cap ]
then CAP=true; shift
fi

TEXT="$*"

if [ "$CAP" ]
then TEXT=`echo "$TEXT" | tr 'qwertyuioplkjhgfdsazxcvbnm' 'QWERTYUIOPLKJHGFDSAZXCVBNM'`
fi

GOODONES="banner big mini script shadow slant small smshadow smslant standard 3x5 acrobatic alligator alphabet avatar banner3-D banner3 banner4 basic bulbhead calgphy2 chunky colossal computer contessa contrast cosmic cricket cursive cyberlarge cybermedium cybersmall doh doom drpepper eftirobot eftitalic eftiwater epic fourtops fuzzy goofy gothic graffiti invita italic jazmine kban larry3d lcd letters linux lockergnome madrid maxfour nancyj nipples o8 ogre pawp pebbles pepper poison puffy rectangles relief rev roman rounded rowancap rozzo sblood script serifcap shadow short slant slide slscript small speed stampatello starwars stop straight tanja thick thin threepoint ticks ticksslant tinker-toy tombstone trek twopoint univers usaflag weird"
# GOODONESRE=`echo "$GOODONES" | sed "s/^/(/;s/$/)/;s/ /|/g"`
GOODONESRE='/('`echo "$GOODONES" | tr ' ' '|'`').flf$'
FIGFONT=`
	find /usr/share/figlet/ \
	     /stuff/mirrors/www.figlet.org/fonts/ \
	     -name "*.flf" |
	egrep "$GOODONESRE" |
	chooserandomline
`
## We get an error from this last line: "sed: Couldn't close {standard output}: Broken pipe", no matter whether we use ls or find
SHORTFIGFONT=`echo "$FIGFONT" | sed 's+^.*/++;s+\.flf$++'`

[ "$COLUMNS" ] || COLUMNS=80

echo
/usr/bin/figlet -w "$COLUMNS" -f "$FIGFONT" "$TEXT"
echo
