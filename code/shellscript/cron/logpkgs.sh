# DATE=`date | sed 's/[^ ]*[ ]*\([^ ]*\)[ ]*\([^ ]*\)[ ]*[^ ]*[ ]*[^ ]*[ ]*\([^ ]\)/\2-\1-\3/'`
DATE=today

export COLUMNS=250
dpkg -l "$@" > $JPATH/logs/debpkgs-list-$DATE.log

dpkgsizes | sort -n -k 1 > $JPATH/logs/debpkgs-sizes-$DATE.log
