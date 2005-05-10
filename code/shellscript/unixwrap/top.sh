## well we want to unexport it cos jsh exports it (useful for some apps, but not top, if you change term size whilst it's running)
unset COLUMNS
unj top c "$@"
# jwatchchanges top c n 1 "$@"
