awk ' BEGIN { n = 0 } { n += $1 } ; END { print n } '
