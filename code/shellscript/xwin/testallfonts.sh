# Some of the TTF fonts I installed caused the X session to bomb :-(
# This script opens an xterm with each font to test which is the evil one.

# This test is not sufficient
# Wine and konqueror are still crashing!
# But they are too slow to do binary tests by hand.

if test "$1" = "reportok"; then
	echo "$2" >> fonts-reported.txt
	exit 0
fi

cp fonts-so-far.txt fonts-reported-last.txt

printf "" > fonts-so-far.txt
printf "" > fonts-reported.txt

(
	fslsfonts -server localhost:7101
) |

grep -v "000000" |

grep "\(win98\|off97\)" |

while read FNT; do

	echo "$FNT" >> fonts-so-far.txt

	# if ! grep "^$FNT" fonts-reported-last.txt; then
		echo "$FNT"
		`jwhich xterm` -font "$FNT" -e testallfonts reportok "$FNT"
	# fi

done
