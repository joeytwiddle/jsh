WIDTH=`\`jwhich man\` "$@" | col -bx | longestline`
WIDTH=`expr $WIDTH + 2`
whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e man "$@"
