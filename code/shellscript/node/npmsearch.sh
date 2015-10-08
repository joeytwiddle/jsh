# See also: https://github.com/josher19/npm-search
#      and: https://www.npmjs.org/package/local-npm
# Apparently npmd can do search also, but I never got that working :P

browse "https://www.npmjs.com/search?q=$*"
exit

memo -nd -t "2 months" npm search . |
sed 's+ *$++' |   # I don't know why but one of the memo-s I cached in June 2014 had a lot of trailing spaces
grep "$@" |
less -REXS        # Chop long lines (don't wrap them); provide pager if more than one screen
