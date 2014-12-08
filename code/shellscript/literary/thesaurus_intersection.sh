#!/bin/sh

if [ "$1" = "--help" ] || [ "$#" != 2 ]
then cat << !

thesaurus_intersection [word1] [word2]

  Looks up thesaurus entries for the given words, and displays those words
  which appear in all entries.

  This can be useful to narrow down the number of suggested words you need to
  read through, if you think the word you are looking for is likely to be
  listed as a synonym for two words you do know.

!
exit
fi

require_exes dict fromline toline tr trimstring trimempty jfcsh || exit

dict -d moby-thesaurus "$1" | fromline -x 'Thesaurus words' | toline -x '^$' | tr ',' '\n' | trimstring | trimempty > /tmp/words1
dict -d moby-thesaurus "$2" | fromline -x 'Thesaurus words' | toline -x '^$' | tr ',' '\n' | trimstring | trimempty > /tmp/words2

jfcsh -common /tmp/words1 /tmp/words2   #| tr '\n' ',' | sed 's/,$// ; s/,/, /g' ; echo

