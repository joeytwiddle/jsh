mkdir -p $HOME/bin &&
wget -nv "http://hwi.ath.cx/projects/imwheel_softmouse/src/imwheel" -O $HOME/bin/imwheel &&
wget -nv "http://hwi.ath.cx/projects/imwheel_softmouse/src/.imwheelrc" -O $HOME/.imwheelrc &&
echo "To run imwheel without detaching, type: \$HOME/bin/imwheel -d" &&
xterm -e $HOME/bin/imwheel -d
