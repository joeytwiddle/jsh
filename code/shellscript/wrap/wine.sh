xset fp- unix/:7101 2>/dev/null
( sleep 1m; xset fp+ unix/:7101 ) &
`jwhich wine` "$@"
