# This is useful for systems which do not suppoer ls --color
# but do support ls -F, so we can search for filetypes!
# It is an approximation of my basic LSCOLS of directories, executables and symlinks.
ls -atrF -C "$@" | highlight "/" green | highlight -bold "*" red | highlight "@" yellow
