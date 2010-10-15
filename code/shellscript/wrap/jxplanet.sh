#!/bin/sh
# In 256 colour mode xplanet does rubbish dithering:
# xplanet -root -projection orthographic -body Earth -blend &
# Instead we can force it to render outside X and dither with xv ...
# ( env DISPLAY= xplanet -output $JPATH/background.jpg -projection orthographic -body Earth -blend -geometry 1024x768 &&
#   xv -root -rmode 5 -maxpect -quit $JPATH/background.jpg )

# Local images for the planet
# FAVEARTHIMG="/usr/share/celestia/textures/earth.jpg"
FAVEARTHIMG="/usr/share/xplanet/images/earth.jpg"
XPID="/usr/share/xplanet/images/"
CLOUDS_URL="http://giga.forfun.net/"

# The cloud image to get from the web
CLIMG="clouds_2048.jpg"
MAPGEOM="2000x1000"

mkdir -p "$HOME/.jxplanetimgs"
cd "$HOME/.jxplanetimgs"

case "$1" in

	"getclouds")

		shift
		# DATE=`date`
		# echo "$DATE: getting clouds" >> $JPATH/logs/jxplanet.txt

		rm $CLIMG
		# header supposed to stop corruption but still occurring:
		wget --header 'Pragma: no-cache' $CLOUDS_URL/$CLIMG
		touch $CLIMG

		# Overlay the clouds onto the planet image.
		export DISPLAY="" # to get xplanet to ignore display geometry.
		xplanet -image $FAVEARTHIMG -cloud_image $CLIMG -shade 100 -output day-clouds.jpg -geometry $MAPGEOM
		xplanet -image $XPID/night.jpg -cloud_image $CLIMG -cloud_shade 30 -output night-clouds.jpg -geometry $MAPGEOM

	;;

	"render")

		shift
		if test ! "$JXPGEOM"; then
		JXPGEOM="1280x1024"
		fi

		ALLARGS="-label -fuzz 20 -image day-clouds.jpg -night_image night-clouds.jpg -projection orthographic -blend -geometry $JXPGEOM -radius 45"

		nice -n 2 env DISPLAY= xplanet -dayside $ALLARGS -output $JPATH/background1.jpg
		xsetbg $JPATH/background1.jpg
		sleep 300
		nice -n 2 env DISPLAY= xplanet -nightside $ALLARGS -output $JPATH/background2.jpg
		nice -n 2 env DISPLAY= xplanet -moonside $ALLARGS -output $JPATH/background3.jpg
		nice -n 2 env DISPLAY= xplanet -random -markers $ALLARGS -output $JPATH/background4.jpg

	;;

	"makeicon")

		shift
		ICONFILE="$1"
		if test "$ICONFILE" = ""; then
			echo "Error: no output icon file specified."
			exit 1
		fi
		# xplanet -projection orthographic -moonside -geometry 64x64 -output "$ICONFILE"
		# To make transparent, we use magenta, and gif/ppms's to retain bytes.
		export DISPLAY="" # to get xplanet to ignore display colormodel.
		ALLARGS="-fuzz 20 -image day-clouds.jpg -night_image night-clouds.jpg -blend -radius 45"
		xplanet -background magenta.ppm -projection orthographic -dayside $ALLARGS -geometry 118x118 -output tmp.ppm
		# convert tmp.ppm -mattecolor "#ff00ff" -frame 10x10+0+0 tmp2.ppm
		convert tmp.ppm -transparency "#ff00ff" "$ICONFILE"
		# Gnome didn't like the ppms (neither did display!) so I ended up writing to a gif.

	;;

	*)

		echo "jxplanet getclouds"
		echo "jxplanet render"
		echo "jxplanet makeicon <iconfile>"
		exit 1

	;;

esac
