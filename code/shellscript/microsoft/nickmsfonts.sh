rm -rf /tmp/nickmsfonts
mkdir -p /tmp/nickmsfonts
cd /tmp/nickmsfonts

echo "================================ Converting to bdf"

(
	`jwhich locate` \.fon
	`jwhich locate` \.fnt
) |

while read MSFNT; do
	fnt2bdf "$MSFNT"
done

echo "================================ Converting to pcf"

for BDFNT in *.bdf; do
	FNT=`echo "$BDFNT" | sed "s/\.bdf//"`
	echo "$FNT"
	bdftopcf -o "$FNT.pcf" "$BDFNT"
done

mkdir fonts
mv *.pcf fonts
mkfontdir fonts

echo
echo "Fontdir created in /tmp/nickmsfonts/fonts/"
echo "(Put this in your XF86Config or type xset fp+ <above> and xset fp rehash.)"
