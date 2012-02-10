## This works on YouTube videos containing aac or ogg audio.
## Thanks pup!
## TODO: We should detect the type before or after, to properly name the output file.

ffmpeg -i "$1" -vn -acodec copy "$1".audio
