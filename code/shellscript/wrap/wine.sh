xset fp- unix/:7101 2>/dev/null
( sleep 2m; xset fp+ unix/:7101 ) &
`jwhich wine` "$@"
