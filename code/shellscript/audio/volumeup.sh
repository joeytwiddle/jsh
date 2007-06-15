HOWMUCH="$1"
if test ! $HOWMUCH; then
	HOWMUCH=6
fi
VOL=`aumix -q | grep "vol" | after "vol " | before ","`
VOL=`expr $VOL + $HOWMUCH`
aumix -v $VOL

VOL=`aumix -q | grep "vol" | after "vol " | before ","`
# echo "[`strrep = $VOL`($VOL)`strrep - $((100-VOL))`]" | osd_cat -c green -d 1 -f -*-freemono-*-r-*-*-*-160-*-*-*-*-*-*
echo "[`strrep = $VOL` |$VOL| `strrep - $((100-VOL))`]" | osd_cat -c green -d 1 -f -*-freemono-*-r-*-*-*-160-*-*-*-*-*-*

