echo "DOESN'T WORK (yet)"
export PS4=`printf "\033[00;31m"`'#dpkg-buildpackage'`printf "\033[00m"`'% '
/bin/sh +x -c "$@"
