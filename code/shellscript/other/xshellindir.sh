# echo `resolvedir "$@"`
gnome-terminal -e "bash -c 'cd `resolvedir "$@"` && bash'"