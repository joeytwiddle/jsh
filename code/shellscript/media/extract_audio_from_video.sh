#!/bin/sh
## Will play the video specified, and output ./audiodump.wav
## -vo null hides the window, -vc dummy greatly improve speed
## Should work on any video or audio input data
mplayer -vo null -vc dummy -ao pcm "$@"
