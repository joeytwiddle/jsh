## Each occurrence (non-overlapping?) of the Perl RE in the stream is printed on an individual line.

EXPR="$@"

perl -n -e " /($EXPR)/ "' && print("$1\n"); '
