## TODO: use of TMPDIR is dodgy!  (to save dependency hugeness?)
## "mel and kim" "respectable" came back wrong!

# jsh-depends: cursered cursenorm filesize diffgraph googlesearch takecols reverse grouplinesbyoccurrence jgettmpdir lynx pipeboth

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
	echo '  Options: -oldmethod / -use <old_dir>'
	echo
	exit 1
fi

## would be nice to name filenames simialr to the url (just strip '/'s "http::" and "www.".

# TMPDIR=`jgettmpdir seeklyrics "$@"`
TMPDIR=`jgettmpdir seeklyrics "$@"`

# rm $TMPDIR/*.lyrics*

## or "normalise"?
strippunctuation () {
	tr -s ' \n' |
	tr -d ',.";?():`'"'" | # !-
	sed 's+\[[^]]*\]++g' |
	sed 's+^[ 	]*++;s+[ 	]*$++'
}

showLinesCoverage () {

	PAGE="$1"
	shift

	cat "$PAGE" |

	while read LINE
	do

		# echo grep -c "^$LINE$" "$@"
		grep -c "^$LINE$" "$@" | grep -v ":0$" |
		countlines | tr -d '\n'

		# echo "	$LINE"
		printf "\t%s\n" "$LINE" # ?

	done

}

N=0

if [ "$1" = -oldmethod ]
then
	OLDMETHOD=true
	shift
fi

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

		# memo lynx -dump "$LINK" |
		memo downloadurl "$LINK" 2>/dev/null | striphtml |
		cat > $TMPDIR/$N.lyrics &&
		echo "$N $LINK" >&2 &

	done

	wait

fi

echo "$N"

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



if [ "$OLDMETHOD" ]
then

	## Old method

	# echo "$TMPDIR"
	# diffgraph $TMPDIR/*.lyrics.nopun | sed "s+$TMPDIR++g"
	# diffgraph -diffcom worddiff $TMPDIR/*.lyrics.nopun
	# diffgraph -diffcom proportionaldiff $TMPDIR/*.lyrics.nopun

	diffgraph $TMPDIR/*.lyrics.nopun |

	pipeboth |

	tee $TMPDIR/diffgraph.out

	cat $TMPDIR/diffgraph.out |
	
	takecols 3 | grouplinesbyoccurrence | sort -n -k 1 | reverse |

	pipeboth |

	head -n 1 |

	while read SCORE PAGE
	do

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


else

	## New method

	cd $TMPDIR
	for N in `seq 1 20`
	do
		if [ -f $N.lyrics.nopun ]
		then

			REST=""
			for M in `seq 1 20`
			do [ ! "$M" = "$N" ] && [ -f $M.lyrics.nopun ] && REST="$REST $M.lyrics.nopun"
			done

			SCORE=`
				showLinesCoverage $N.lyrics.nopun $REST |

				grep -v "	\(References\|lyrics\|\)$" |

				removeduplicatelinespo |

				grep -v "^0	" |
				# grep -v "^[012]	" |
				sort -n -k 1 | reverse |
				pipeboth |

				takecols 1 |
				awksum
			`
			echo "SCORE $SCORE FOR	$N.lyrics.nopun"
			echo

		fi
	done

fi

echo "Get it from: $TMPDIR"

# jdeltmp $TMPDIR

