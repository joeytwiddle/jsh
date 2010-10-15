#!/bin/sh
(

cat << !
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg
   style="fill:#000000;fill-opacity:0.5;stroke:none"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   width="595.275591"
   height="841.889764"
   id="svg1"
   sodipodi:docbase="/tmp/"
   sodipodi:docname="/tmp/mistral.sod">
  <defs
     id="defs3" />
  <sodipodi:namedview
     id="base" />
!

export N=0
export X=20
export Y=30

xlsfonts | grep "^TTUP" | sed "s/^TTUP[^_]*_//" |
# Really should transfer to font-weight, style etc:
grep -v " Italic$" | grep -v " Bold$" |
sort |

while read FONT
do
	export N=`expr $N + 1`
cat << !
  <text
     style="fill:#000000; stroke:none; font-family:$FONT; font-style:normal; font-weight:normal; font-size:16.000000; fill-opacity:1; fill-rule:evenodd; stroke-opacity:1; stroke-width:1px; stroke-linejoin:miter; stroke-linecap:butt; "
     x="$X"
     y="$Y"
     id="text$N">$FONT</text>
!
	export Y=`expr $Y + 15`
	if test "$Y" -gt "800"; then
		export Y=30
		export X=`expr "$X" + 200`
	fi
done

cat << !
</svg>
!

) > allfonts.svg
