# This is useful for systems which do not suppoer ls --color
# but do support ls -F, so we can search for filetypes!
ls -atrF -C "$@" | highlight "/" green | highlight -bold "*" red | highlight "@" yellow
