# really I only want to ungrep "warning, no entries deleted from font path" the error stream, in case anything unexpected is wrong with the command.
xset fp- unix/:7101 2>/dev/null
`jwhich wine` "$@"
xset fp+ unix/:7101 # should solve above problem!
