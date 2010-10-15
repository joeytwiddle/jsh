#!/bin/sh
## lool, 7/4/05: See grep -o !!

## Prints (non-overlapping?) occurrences of the given (perl) regular expression found in the stream, each on an individual line.
## The -atom option specifies that only the first bracketed atom matched should be echoed, allowing you to extract onlt a part of each matched string.

# jsh-ext-depends: perl
## Maybe I could make a grep+sed version.

### Troubleshooting:
## If you are getting the error: "unmatched ( marked by <-- HERE", but your brackets are matched, then the problem is probably that you need to escape your '/'s as "\/"s, because unescaped they end the perl expression.

if [ "$1" = -atom ]
then shift; EXPR="$@"
else EXPR="(""$@"")"
fi

perl -n -e '
  while ( /'"$EXPR"'/g ) {
    print("$1\n");
  }
'
