 # xv is centralised and smoothscales =)
xv -root -rmode 5 -maxpect -quit "$@" 1>&2 ||
## xsetbg is faster, but sometimes poor aspect for tall pictures, and doesn't support bmp
# `jwhich xsetbg` -dither -fullscreen -border black "$@" ||
`jwhich xsetbg` -fullscreen -onroot -fit -border black "$@" ||
## xsetroot is just pants
xsetroot -bitmap "$@" 1>&2
