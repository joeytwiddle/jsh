#!/bin/sh
## Uses mplayer to extract a wav/pcm file from the video/audio file.
## -vo null hides the window, -vc dummy greatly improves speed
outfile="$1.wav"
mplayer -vc null -vo null -ao pcm:fast:file="$outfile" "$@"
