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

if [ "$1" = -use ]
then

	## Re-use previous retrieval
	TMPDIR="$2"
	shift; shift

else

	LINKS=`
		memo googlesearch -links "$@" "lyrics"
		# | pipeboth
	`


	## TODO: should strip duplicate hostnames

	for LINK in $LINKS
	do

		N=$[$N+1]

		memo lynx -dump "$LINK" |
		# downloadurl "$LINK" 2>/dev/null | striphtml |
		cat > $TMPDIR/$N.lyrics &&
		echo "$N $LINK" >&2 &

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

tee $TMPDIR/diffgraph.out |

takecols 3 | grouplinesbyoccurrence | sort -n -k 1 | reverse |

pipeboth |

head -1 |

while read SCORE PAGE
do

	showLinesCoverage () {

		PAGE="$1"
		shift

		cat "$PAGE" |

		while read LINE
		do

			# echo grep -c "^$LINE$" "$@"
			grep -c "^$LINE$" "$@" | grep -v ":0$" |
			countlines | tr -d '\n'

			echo "	$LINE"

		done

	}
		

	CHILDREN=`
		cat $TMPDIR/diffgraph.out | takecols 1 3 |
		grep "$PAGE$" |
		# pipeboth |
		takecols 1
	`

	# more "$PAGE"
	echo "`curseyellow`Showing line coverage of $PAGE against:" $CHILDREN"`cursenorm`"
	showLinesCoverage "$PAGE" $CHILDREN

done

# jdeltmp $TMPDIR
