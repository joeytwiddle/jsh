# jsh-depends: cursered cursenorm filesize diffgraph googlesearch takecols reverse grouplinesbyoccurrence jgettmpdir lynx pipeboth
## "mel and kim" "respectable" came back badly!

## The web is fuzzy:
#    - Need to kill discography listings!
#    - There are also quite a few pages containing lyrics for a group of songs

if [ ! "$*" ]
then
	echo
	echo 'seeklyrics "<artist>" "<song title>" [ "<part of song>" ] [ "-<other title>" ]*'
	echo
	echo '  Either of the latter two help in narrowing down on the particular song, and'
	echo '  avoiding song listings.  =)'
	echo
	exit 1
fi

## would be nice to name filenames simialr to the url (just strip '/'s "http::" and "www.".

# TMPDIR=`jgettmpdir seeklyrics "$@"`
TMPDIR=`jgettmpdir seeklyrics`

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

		echo "$N $LINK" >&2
		# wget -O - "$LINK" |
		lynx -dump "$LINK" > $TMPDIR/$N.lyrics

	done

	wait

fi

for N in `seq 1 20`
do

	## We drop small files.   Shouldn't we just weigh against small files proportional to their ability to be chosen as ancestors?
	if [ -f $TMPDIR/$N.lyrics ] && [ ! `filesize $TMPDIR/$N.lyrics` -lt 1024 ]
	then
		cat $TMPDIR/$N.lyrics |
		strippunctuation |
		cat > $TMPDIR/$N.lyrics.nopun
	else
		echo "`cursered`$TMPDIR/$N.lyrics not found or <1k so skipping.`cursenorm`"
	fi

done

# echo "$TMPDIR"
# diffgraph $TMPDIR/*.lyrics.nopun | sed "s+$TMPDIR++g"
# diffgraph -diffcom worddiff $TMPDIR/*.lyrics.nopun
# diffgraph -diffcom proportionaldiff $TMPDIR/*.lyrics.nopun

diffgraph $TMPDIR/*.lyrics.nopun |

pipeboth |

takecols 3 | grouplinesbyoccurrence | sort -n -k 1 | reverse |

pipeboth |

head -1 |

while read SCORE PAGE
do

	more "$PAGE"

done

# jdeltmp $TMPDIR
