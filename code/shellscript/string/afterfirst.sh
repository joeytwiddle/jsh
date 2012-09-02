#!/bin/sh
# jsh-ext-depends: sed

## I just cannot do it properly with sed.  :-(
## I think it's impossible, due to sed's greediness.

## But, it might be possible to do it properly, if the search string is a single char, using [^$CHAR]
## So maybe a less ugly implementation would be appropriate for that special case.

## Note, whilst it's impossible to properly reproduce afterfirst in sed for strings, if the search argument is just one character:
# sed "s+^[^$CHAR]*$CHAR++"

# Ugh
# SPECIALSTR="nobodyWo0ldn6teverUsastwiunglikevish_unlessOfCourseTh3yw3r34<<355/|\|gthisFile!"
SPECIALSTR="nbdW0d6eeUatinlkvs"
sed "s$@\(.*\)$SPECIALSTR\1" | sed "s.*$SPECIALSTR"

## OK so we can't replace the stuff before away, because we can only match it greedily.
## But what we could do is match the thing we want to keep greedily, and throw the rest away.
## This broke slowgetauth on spud!  afterfirst "<[^>]*> *[^ ]* "
## I think perhaps it breaks the original behaviour, of doing nothing if our regexp is not found?
# grep -o "$*.*" | sed "s^$*"

## Nope:
# sed "s+.\($@.*\)+\1+g"

# # Ugh
# while read X; do
  # Y=`echo "$X" | sed "s|$*.*||"`
  # # echo "y=$Y"
  # echo "$X" | sed "s|^$Y$*||"
# done

# This is actually afterfirstall !

# Problem is sed doesn't do non-greedy matching
# need context, but at this level of abstraction we need to ensure
# .* does not match do "$*"
# sed "s+$*.*++"
# Untested.  I expect it gets only the first argument!
# tr "\n" " " | awk ' BEGIN { FS="'"$1"'" } { printf($2"\n") } '

# OK here we use greedy matching on the right hand side
# and using awk, extract the text which matched the RE.

## Hmmm I don't remember why I commented this out; maybe the ugly sed version is more efficient, maybe not!  :P

# awk '
  # BEGIN {
    # SRCHLEN=length("'"$*"'");
  # }
  # function extract(s,re) {
    # match(s,re);
    # return substr(s,RSTART+SRCHLEN,RLENGTH-SRCHLEN);
  # }
  # {
    # for ( s=$0 ; t = extract(s,"'"$*.*"'") ; s = substr(s,RSTART+RLENGTH) )
      # print t;
  # }
# '
