tail -1 $JPATH/logs/xmms.log | afterlast ">" | beforelast "<"

## For xmms:
#/usr/sbin/lsof -c xmms |  grep -v /lib/ | grep -v "\(/tmp\|/dev/null\|/usr/bin/xmms\|/dev/dsp.\|/dev/pts.\|/dev/pts..\|pipe\|socket\|/\|/tmp/xmms_[^ ]*\)$" | drop 1 | dropcols 1 2 3 4 5 6 7 8 | removeduplicatelines
