#!/bin/sh
# @packages faac gpac

# set -x
set -e

INFILE="$1"
if [ ! -f "$INFILE" ]
then
	echo
	echo "reencode_video_to_x264 <video_file>"
	echo
	echo "  Options: OUTSIZE, FPS, SCALEOPTS, PREVIEW, LOSS, AUDIOQUALITY"
	echo
	exit 1
fi
[ "$OUTFILE" ] || OUTFILE="$INFILE.x264.mp4"

## TODO: Input size and fps could be obtained from mplayer's output line starting "VIDEO:"

## OUTSIZE should be input size, unless we are scaling with SCALEOPTS
# [ "$OUTSIZE" ] || OUTSIZE=720x480
[ "$OUTSIZE" ] || OUTSIZE=608x336
# [ "$OUTSIZE" ] || OUTSIZE=480x320
[ "$FPS" ] || FPS=23.976
# [ "$SCALEOPTS" ] || SCALEOPTS="scale=480:320,"   ## don't forget the comma!
# PREVIEW="-ss 0:00:00 -endpos 0:10"
# [ "$LOSS" ] || LOSS=26 ## web quality
[ "$LOSS" ] || LOSS=12 ## video quality
# [ "$LOSS" ] || LOSS=8 ## film quality
# [ "$LOSS" ] || LOSS=16
[ "$AUDIOQUALITY" ] || AUDIOQUALITY=50   # 100

cleanup() {
	del audiodump.wav audiodump.aac
}

[ -f audiodump.wav ] || mplayer -ao pcm -vc null -vo null "$INFILE"
[ -f audiodump.aac ] || faac -q "$AUDIOQUALITY" --mpeg-vers 4 audiodump.wav

rm -f tmp.fifo.yuv
mkfifo tmp.fifo.yuv

mencoder $PREVIEW -vf "$SCALEOPTS"format=i420 -nosound -ovc raw -of rawvideo -ofps "$FPS" -o tmp.fifo.yuv "$INFILE" 2>&1 > /dev/null &

## Basic:
# x264 -o "$OUTFILE" --fps "$FPS" --crf "$LOSS" --progress tmp.fifo.yuv "$OUTSIZE"

## For Quicktime:
x264 -o "$OUTFILE" --fps "$FPS" --bframes 2 --progress --crf "$LOSS" --subme 6 --analyse p8x8,b8x8,i4x4,p4x4 --no-psnr tmp.fifo.yuv "$OUTSIZE"

rm tmp.fifo.yuv

## Combine audo and video:
MP4Box -add "$OUTFILE" -add audiodump.aac -fps "$FPS" "$OUTFILE".with_video

mv -f "$OUTFILE".with_video "$OUTFILE"

