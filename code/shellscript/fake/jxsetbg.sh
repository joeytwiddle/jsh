# xv is centralised =)
xv -root -rmode 5 -maxpect -quit "$@" 1>&2 ||
# xsetbg tiles
`jwhich xsetbg` "$@" ||
# xsetroot is just pants
xsetroot -bitmap "$@" 1>&2
