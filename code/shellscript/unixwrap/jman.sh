WIDTH=`man "$@" | col -bx | longestline`
WIDTH=`expr $WIDTH + 2`
whitewin -geometry "$WIDTH"x60 -e man "$@"
