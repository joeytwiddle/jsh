# See also: https://github.com/josher19/npm-search
#      and: https://www.npmjs.org/package/local-npm
# Apparently npmd can do search also, but I never got that working :P

#browse "https://www.npmjs.com/search?q=$*"
#browse "https://npmsearch.com/?q=$*"

# We now have this
#npm search "$*"
#npm search --long "$*"

# npms shows the scores for each match
# We only install if not already.  This is significantly faster than prefixing with: npx -p npms-cli ...
if ! which npms >/dev/null 2>&1
then npm install -g npms-cli
fi
# The cat fixes a bug where the terminal became broken if the results included weird chars.  See: https://github.com/npms-io/npms-cli/issues/52
npms search --color -s 250 "$*" 2>&1 | cat | less -REX

# Performs a daily download, but not so bloated as npm's.  (About 1 minute.)
# It orders things by stars, but it also seems to skip some packages with 0 stars.
#nipster "$*"
exit



memo -nd -t "2 months" npm search . |
sed 's+ *$++' |   # I don't know why but one of the memo-s I cached in June 2014 had a lot of trailing spaces
grep "$@" |
less -REXS        # Chop long lines (don't wrap them); provide pager if more than one screen
