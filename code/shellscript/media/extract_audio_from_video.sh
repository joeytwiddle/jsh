## This works on some YouTube videos containing aac or ogg audio.  Thanks pup!
## But it fails on many other video formats.
## If it does not work on the video you have, you can try instead:
##   convert_to_ogg or convert_to_mp3 or dump_audio_from

## TODO: We should detect the type before or after, to properly name the output file.

## If ffmpeg is not available, try avconv from package libav-tools
## avconv seems to need the correct file extension for the output file.

avconv -i "$1" -vn -acodec copy "$1".aac

