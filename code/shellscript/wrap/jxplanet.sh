# In 256 colour mode xplanet does rubbish dithering:
# xplanet -root -projection orthographic -body Earth -blend &
# Instead we can force it to render outside X and dither with xv ...
# ( env DISPLAY= xplanet -output $JPATH/background.jpg -projection orthographic -body Earth -blend -geometry 1024x768 &&
#   xv -root -rmode 5 -maxpect -quit $JPATH/background.jpg )

cd $HOME/.jxplanetimgs

# Local images for the planet
FAVEARTHIMG="/usr/share/celestia/textures/earth.jpg"
XPID="/usr/share/xplanet/images/"

# The cloud image to get from the web
CLIMG="clouds_2000.jpg"
MAPGEOM="2000x1000"

case "$1" in

	"getclouds")

		shift
		# DATE=`date`
		# echo "$DATE: getting clouds" >> $JPATH/logs/jxplanet.txt

		rm $CLIMG
		# header supposed to stop corruption but still occurring:
		wget --header 'Pragma: no-cache' http://xplanet.sourceforge.net/$CLIMG
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

		ALLARGS="-label -fuzz 20 $@ -image day-clouds.jpg -night_image night-clouds.jpg -projection orthographic -blend -geometry $JXPGEOM -radius 45"

		nice -n 2 env DISPLAY= xplanet -dayside $ALLARGS -output $JPATH/background1.jpg
		xv -root -rmode 5 -maxpect -quit $JPATH/background1.jpg
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
		# xplanet -background trans.png -projection orthographic -moonside -geometry 64x64 -output "$ICONFILE"
		xplanet -projection orthographic -moonside -geometry 64x64 -output "$ICONFILE"

	;;

	*)

		echo "jxplanet getclouds"
		echo "jxplanet render"
		echo "jxplanet makeicon <iconfile>"
		exit 1

	;;

esac
