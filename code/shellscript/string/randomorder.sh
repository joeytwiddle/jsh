#!/bin/sh
# jsh-ext-depends: sort
# jsh-depends: afterfirstall

[ -e /dev/urandom ] && export USE_RND_DEV=true

### === bash method ===
while IFS="" read LINE
do
	printf "%s\n" "$RANDOM $LINE"
	## Slow, even with urandom:
	# RND=`getrandom`
	# printf "%s\n" "$RND $LINE"
done |
sort -n -k 1 |
afterfirst ' '

exit

### === awk method ===

## TODO: if randomorder is imported as a function into another script,
##       and used more than once,
##       then its seed remains the same.  :-(
## Eh?  Is that really true?
# SEED="$$"

# #!/usr/local/bin/zsh
# /usr/bin/nawk '

# SEED=`date +%N`
# SEED="$RANDOM$RANDOM"
# SEED=`date +%N | sed 's+000$++'`"$$"
SEED=`getrandom`
# jshinfo "SEED=$SEED"

## This was what runoneof was supposed to do :P
## Eek, last time I tried it was awful :E
AWK=awk
## TODO: Er, I think these tests need re-doing...
# which mawk >/dev/null 2>&1 && AWK=mawk ## didn't seem very random to me
# which gawk >/dev/null 2>&1 && AWK=gawk ## skip it; it's what my system has by default

    # // printf(int(123456*rand()));
    # // srand('"$SEED"'+123456789*rand()+systime());
    # // printf(int(123456789*rand()));
"$AWK" '
  BEGIN {
    FS="\n";
    // srand('$$');
    srand('"$SEED"');
  }
  {
    printf(int(123456*rand()));
    printf(" ");
    printf("%s",$1);
    printf("\n");
  }
' "$@" |
  sort -n -k 1 |
	# pipeboth |
  afterfirstall " "
	# cat
