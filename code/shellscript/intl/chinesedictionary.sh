export LANG=fake # otherwise crxvt hangs.
FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso8859-1'
echo "1 _"
echo "2 /"
echo "3 v"
echo "4 \\"
crxvt +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" \
	-im xcin -pt Root -e /usr/bin/cedictlookup -vd /usr/share/cedict

# Taken out 'cos it asks anyway then goes for provided! -vf cedict.b5
