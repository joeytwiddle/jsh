DATE=`date | sed 's/[^ ]* \([^ ]*\) \([^ ]*\) [^ ]* [^ ]* \([^ ]\)/\2-\1-\3/'`

export COLUMNS=250
dpkg -l "$@" > $JPATH/logs/debpkgs-$DATE.list.log

dpkgsizes | sort -n -k 1 > $JPATH/logs/debpkgs-$DATE.sizes.log
