memo -nd -t "2 months" npm search . |
sed 's+ *$++' |   # I don't know why but one of the memo-s I cached in June 2014 had a lot of trailing spaces
grep "$@"
