#!/bin/zsh
DESTIMGFILE=googlerip.jpg
LEFTIMGFILE=googleripleft.jpg
RIGHTIMGFILE=googleripright.jpg
mkdir -p $HOME/.ripgoogle
cd $HOME/.ripgoogle
# Loses original.gif: 'rm' -rf *

# rm -f index.html
wget -N www.google.com

HREF=`cat index.html |
                grep "img=" | head -1 |
				grep "href=" |
				afterfirst "href=" |
				between '\"' |
				head -n 1`
HREF=`tourl "$HREF" "www.google.com"`
echo "Got href=>$HREF<"

# IMG="original.gif"
# IMGFILE="original.gif"
IMG=`cat index.html |
			grep img | head -1 |
			afterfirst img | afterfirst src= | beforefirst " " |
			tr -d '"'`
echo "Getting image >$IMG<"
wget "http://www.google.com/$IMG"
IMGFILE=`echo $IMG | after /`
echo "Got image=>$IMGFILE<"
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
cp finaljumpgate.html $JPATH/org/jumpgate.html
cp $LEFTIMGFILE $JPATH/org/
cp $RIGHTIMGFILE $JPATH/org/
# mv $DESTIMGFILE $JPATH/org/
