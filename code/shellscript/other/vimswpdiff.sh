vi -r "$@" "+w tmp.txt" "+q"
jfc "$@" tmp.txt
