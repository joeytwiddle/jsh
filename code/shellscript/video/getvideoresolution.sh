ffmpeg -i "$1" 2>&1 | grep Video | grep -o "[0-9][0-9]*x[0-9][0-9]*"
