## Only tested on up-to-date checkout :P
cvs status "$@" |
grep "^File:" |
# takecols 4 2
# dropcols 1 3
sed ' s+^File: ++ ; s+\<Status: ++ '

