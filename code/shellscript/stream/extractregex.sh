## Each (non-overlapping?) occurrence in the stream of the Perl RE is printed on an individual line.
## Option -atom specifies that only the first bracketed atom matched should be echoed.

## FAQ:
##   Q) Why am I getting error "unmatched ( marked by <-- HERE" when my brackets are matched?
##   A) You have probably terminated the perl regexp prematurely with the special symbol '/' which you should replace with "\/".

if [ "$1" = -atom ]
then shift; EXPR="$@"
else EXPR="(""$@"")"
fi

perl -n -e '
  while ( /'"$EXPR"'/g ) {
    print("$1\n");
  }
'
