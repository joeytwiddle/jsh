## "mel and kim" "respectable" came back badly!

## The web is fuzzy:
#    - Need to kill discography listings!
#    - There are also quite a few pages containing lyrics for a group of songs

## usage: seeklyrics "<artist>" "<part of song title>" [ "<tiny part of song>" ] [ "-<other song titles>" ]
## either of the latter two help in narrowing down on the particular song, and avoiding song listings =)

## would be nice to name filenames simialr to the url (just strip '/'s "http::" and "www.".

TMPDIR=`jgettmpdir seeklyrics "$@"`

# rm $TMPDIR/*.lyrics*

N=0

## or "normalise"?
strippunctuation () {
	tr -s ' \n' |
	tr -d ',.";?():`'"'" | # !-
	sed 's+\[[^]]*\]++g' |
	sed 's+^[ 	]*++;s+[ 	]*$++'
}

if [ "$1" = -skip ]
then shift
else

	googlesearch -links "$@" "lyrics" |

	# pipeboth |

	## TODO: should strip duplicate hostnames

	while read LINK
	do

		N=$[$N+1]
		echo "$N $LINK"

	done |

	## I know this is crazy

	while read N LINK
	do

		# wget -O - "$LINK" |
		echo "$LINK" >&2
		lynx -dump "$LINK" | cat > $TMPDIR/$N.lyrics &

	done

	wait

fi

for N in `seq 1 20`
do

	if [ -f $TMPDIR/$N.lyrics ] && [ ! `filesize $TMPDIR/$N.lyrics` -lt 1024 ]
	then
		cat $TMPDIR/$N.lyrics |
		strippunctuation |
		cat > $TMPDIR/$N.lyrics.nopun
	fi

done

# echo "$TMPDIR"
# diffgraph $TMPDIR/*.lyrics.nopun | sed "s+$TMPDIR++g"
# diffgraph -diffcom worddiff $TMPDIR/*.lyrics.nopun
# diffgraph -diffcom proportionaldiff $TMPDIR/*.lyrics.nopun

diffgraph $TMPDIR/*.lyrics.nopun |

pipeboth |

## drop columns 1 and 2, yeah and drop 4+, just take #3 (their duplicity should weight again st them?    nah but it shouldn't weight for them either)
## then see which one is most common.  it may be the lyrics!

takecols 3 |

grouplinesbyoccurrence |

sort -n -k 1 |

reverse

# jdeltmp $TMPDIR
