## Outputs seconds as a decimal
mplayer -vo null -ao null -frames 0 -identify "$1" 2>/dev/null | grep "^ID_LENGTH=" | sed 's+^[^=]*=++'

## An alternative:
# ffmpeg -i "$1" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//
## This outputs hours:minutes:seconds.centiseconds
## We should do further processing to produce answer in seconds
