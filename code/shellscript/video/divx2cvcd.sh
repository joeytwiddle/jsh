#!/bin/bash

## Shamelessly stolen for jsh from: http://dvdripping-guid.berlios.de/Divx-to-VCD_en.html
## TODO: script has a bug which means it doesn't work on "./<filename>".  Fix it.  (It happens cos basename "./<file>" != "<file>" !)

# Este script pasa un Divx a CVCD. Para los archivos temporales se
# necesita al menos 4.5 Gigas (mpv y mpa, los .mpg y los .bin)

# This script conversts a Divx file to CVCD. For temp files, it
# needs at least 4.5 Gb free (mpv, mpa, .mpg and .bin files)

# If movie length can't be determined by tcprobe, it will use
# this value (1 hour and 53 minutes). If your file is not an avi
# you can set here its length in seconds to get the CVCD adjusted
# to fit on the CD with maximum bitrate
# DEFAULT_MOVIE_SECONDS=6800
DEFAULT_MOVIE_SECONDS=2880 # Joey

# Default is to transcode a file with 16:9 (most divx files)
# If you want to transcode a file in 4:3 (letterboxed), like a
# recording from TV, you need to change this to "-M BICUBIC"
SCALING="-M BICUBIC"
#SCALING="-M WIDE2STD"

# CDSIZE Values. VCDs are write in Mode 2, so the filesizes are the
# the following: 
# 	74 Min/650Mb ---> CDSIZE=735
#	80 Min/700Mb ---> CDSIZE=795
CDSIZE=795

# Quantum is the quality, values are 1-31,
# the nearest to 1, the better
QUANTUM=3
# Audio bitrate for the mp2 stream
AUDIORATE=128

if [ $# -eq 0 ]; then
	echo "Usage:"
	echo "        divx2cvcd <divxfile> [mplayer-params]"
	exit 1
fi

DIR=`pwd`
TEMPFOLDER=/tmp/divx2vcd-$RANDOM
TEMP_TEMPLATE=/tmp/tcmplex-template-$RANDOM
LOG="$DIR/log"
rm $LOG

FILE=$1
if [ "$1" == "`basename \"$1\"`" ]; then
	FILE="$DIR/$1"
fi

shift 1
MPLAYER_PARAMS=$*

mkdir $TEMPFOLDER
cd $TEMPFOLDER

tcprobe -i "$FILE" > $TEMPFOLDER/info

WIDTH=`grep '\[avilib\] V:' $TEMPFOLDER/info | \
  perl -e ' $line=<STDIN> ; $line =~ /width=(\d+)/  ;  print $1' `
HEIGHT=`grep '\[avilib\] V:' $TEMPFOLDER/info | \
  perl -e ' $line=<STDIN> ; $line =~ /height=(\d+)/  ;  print $1' `
FPS=`grep 'frame rate' $TEMPFOLDER/info | \
  perl -e ' $line=<STDIN> ; $line =~ /frame rate: -f (.+?) \[/  ;  print $1' `
FPS_1=`echo "scale=1 ; $FPS/1"| bc -l`
FRAMES=`grep '\[avilib\] V:' $TEMPFOLDER/info | \
  perl -e ' $line=<STDIN> ; $line =~ /frames=(\d+)/  ;  print $1' `
SEGUNDOS_TOTAL=`echo "scale=0 ; ($FRAMES / $FPS)"| bc -l`
#If couldn't get the length, use the default
[ "$SEGUNDOS_TOTAL" == "" ] && SEGUNDOS_TOTAL=$DEFAULT_MOVIE_SECONDS
HORAS=`echo "scale=0 ; ($SEGUNDOS_TOTAL / 3600)"| bc -l`
MINUTOS=`echo "scale=0 ; (($SEGUNDOS_TOTAL - \
  3600 * $HORAS)/60)"| bc -l`
SEGUNDOS=`echo "scale=0 ; ($SEGUNDOS_TOTAL % 60)"| bc -l`

VIDEO_RATE=`echo "scale=0 ;(($CDSIZE * 1024 - \
  ($AUDIORATE/8*$SEGUNDOS_TOTAL))*8 / $SEGUNDOS_TOTAL)"| bc -l`

MAXRATE=$VIDEO_RATE
[ "$MAXRATE" == "" ] && MAXRATE=1050
[ $MAXRATE -gt 2000 ] && MAXRATE=2000


echo "*************** FILE INFO ***************" >> $LOG
echo "Frame Size: ${WIDTH}x${HEIGHT}  -   FPS: $FPS" >> $LOG
echo "Length: $FRAMES   -  Seconds: $SEGUNDOS_TOTAL" >> $LOG
echo "$HORAS hours, $MINUTOS minutes, $SEGUNDOS seconds" >> $LOG
echo "Recommended averagge video bitrate: $VIDEO_RATE" >> $LOG
echo -e "Using max video bitrate: $MAXRATE \n" >> $LOG

FRAMERATE=""
NORM=""
if [ $FPS_1 == "29.9" -o $FPS_1 == "30" -o  $FPS_1 == "23.9" -o $FPS_1 == "24" ]; then
	WIDTH_OUT=352
	HEIGHT_OUT=240
	NORM="-n n"
	[ $FPS_1 == "29.9" ] && FRAMERATE="-F 4"
	[ $FPS_1 == "30" ] && FRAMERATE="-F 5"
	[ $FPS_1 == "23.9" ] && FRAMERATE="-F 1"
	[ $FPS_1 == "24" ] && FRAMERATE="-F 2"
else
	WIDTH_OUT=352
	HEIGHT_OUT=288
fi



echo "Video Output: ${WIDTH_OUT}x${HEIGHT_OUT}"

# Ahora calculamos los valores pa los bordes.

ANCHO_1_1_OUT=`echo "($HEIGHT_OUT * 4/3)"| bc -l`
ALTO_OUT=`echo "$HEIGHT / ($WIDTH / $ANCHO_1_1_OUT)" | bc -l`
# Redondeamos
ALTO_OUT=`echo "scale=0 ; $ALTO_OUT/1"| bc -l`
# Nos aseguramos de que sea par
ALTO_OUT=`echo "scale=0 ; $ALTO_OUT+$ALTO_OUT%2" | bc -l`

BORDE=`echo "scale=0 ; ($HEIGHT_OUT-$ALTO_OUT)/2"| bc -l`

echo "alto sin bordes: $ALTO_OUT, con borde: $BORDE"

# Borramos Pelicula.mpv y Pelicula.mpa
rm -f Pelicula.mpv Pelicula.mpa 


cd $TEMPFOLDER


mkfifo -m 660 stream.yuv
mkfifo -m 660 audiodump.wav

echo "mplayer -noframedrop -vo yuv4mpeg -ao pcm -waveheader \
    -v -osdlevel 0 $MPLAYER_PARAMS \"$FILE\" &
    " >> $LOG

mplayer -noframedrop -vo yuv4mpeg -ao pcm -waveheader \
    -v -osdlevel 0 $MPLAYER_PARAMS "$FILE" &

echo "(cat stream.yuv | yuvscaler -v 0 $SCALING -O VCD $NORM | \
    mpeg2enc -v 0 -s -f 2 -b $MAXRATE -q $QUANTUM $FRAMERATE $NORM -4 2 -2 1 \
       -o $DIR/Pelicula.mpv) &
       "  >> $LOG

(cat stream.yuv | yuvscaler -v 0 $SCALING -O VCD $NORM | \
    mpeg2enc -v 0 -s -f 2 -b $MAXRATE -q $QUANTUM $FRAMERATE $NORM -4 2 -2 1 \
       -o $DIR/Pelicula.mpv) &

mp2enc -b $AUDIORATE -r 44100 -o $DIR/Pelicula.mpa < audiodump.wav &

wait


RETVAL=$?
if [ $RETVAL -ne 0 ]; then
	echo -e "\n**** ERROR during transcoding. Error value $RETVAL"
	exit 1
fi


rm $TEMPFOLDER/*
rmdir $TEMPFOLDER

cd $DIR


# Si no hay Pelicula.mpv y Pelicula.mpa salir
[ -f Pelicula.mpv -a -f Pelicula.mpa ] || exit 1

rm -f Pelicula*.mpg

#Ahora multiplexamos el mpg
echo "maxFileSize = $CDSIZE" > $TEMP_TEMPLATE
tcmplex -i Pelicula.mpv -p Pelicula.mpa -o Pelicula.mpg \
  -m 1 -F $TEMP_TEMPLATE

rm $TEMP_TEMPLATE


[ -n "`ls Pelicula*mpg 2> /dev/null`" ] || exit 1

# Y creamos las imagenes...
for i in `ls Pelicula*.mpg` ; do
	vcdimager -t vcd2 -c $i.cue -b $i.bin $i
	RETVAL=$?
	if [ $RETVAL -ne 0 ]; then
		echo -e "\n**** ERROR creating VCD images. Error value $RETVAL"
		exit 1
	fi
done

echo -e "\n****** CVCD creation finished successfully"
