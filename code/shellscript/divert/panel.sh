cd $HOME
mv .gnome-last.tgz .gnome-prev.tgz
tar cfz .gnome-last.tgz .gnome
xterm -e `jwhich panel`
