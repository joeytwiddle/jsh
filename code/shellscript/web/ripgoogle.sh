#!/bin/zsh
DESTIMGFILE=googlerip.jpg
LEFTIMGFILE=googleripleft.jpg
RIGHTIMGFILE=googleripright.jpg
mkdir -p $HOME/.ripgoogle
cd $HOME/.ripgoogle
# Loses original.gif: 'rm' -rf *

wget www.google.com

HREF=`cat index.html | afterfirst "href=" | beforefirst ">" | between '\"' | head -n 1`
HREF=`tourl "$HREF" "www.google.com"`
echo "Got href=>$HREF<"

# IMG=`cat index.html | afterfirst 'img' | afterfirst 'src=' | tr "\n" " " | sed "s/\ .*//g"`
# echo "Getting image >$IMG<"
# wget "http://www.google.com/$IMG"
# IMGFILE=`echo $IMG | after /`
# echo "Got image=>$IMGFILE<"
IMG="original.gif"
IMGFILE="original.gif"
convert $IMGFILE -geom 60 -quality 100 $DESTIMGFILE
IMGSIZE=`imagesize $DESTIMGFILE`
# echo "Got image size=>$IMGSIZE<"
IMGWIDTH=`echo $IMGSIZE | before "x"`
IMGHEIGHT=`echo $IMGSIZE | after "x"`
echo "Got image size=>$IMGWIDTH"x"$IMGHEIGHT<"
HALFIMGWIDTH=$[$IMGWIDTH/2];
HALFIMGWIDTHMAJ=$[$[$IMGWIDTH+1]/2];
IMGWIDTHPLUS=$[$IMGWIDTH+12];
# echo "Split to >$HALFIMGWIDTH and $HALFIMGWIDTHMAJ<"
convert $DESTIMGFILE -crop $HALFIMGWIDTH"x"$IMGHEIGHT+0+0 $LEFTIMGFILE
convert $DESTIMGFILE -crop $HALFIMGWIDTH"x"$IMGHEIGHT+$HALFIMGWIDTHMAJ+0 $RIGHTIMGFILE

# LINE='                <a href='$HREF'><img border="0" align="middle" src="'$DESTIMGFILE'"></a>'
LINE='                <td width="'$IMGWIDTHPLUS'" valign="middle" align="center"><a href="http://www.google.com/"><img alt="(Home)" border="0" align="middle" src="'$LEFTIMGFILE'"></a><a alt="(Topical)" href='$HREF'><img border="0" align="middle" src="'$RIGHTIMGFILE'"></a></td>'

cp $JPATH/org/jumpgate.html jumpgate-orig.html
replaceline jumpgate-orig.html "<\!-- #~googleimage~# -->" "<\!-- #~googleimage~# -->$LINE" > finaljumpgate.html

# Move the final files over the originals
mv finaljumpgate.html $JPATH/org/jumpgate.html
mv $LEFTIMGFILE $JPATH/org/
mv $RIGHTIMGFILE $JPATH/org/
# mv $DESTIMGFILE $JPATH/org/
