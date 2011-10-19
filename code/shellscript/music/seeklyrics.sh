#!/bin/bash
## TODO: use of TMPDIR is dodgy!  (to save dependency hugeness?)
## "mel and kim" "respectable" came back wrong!

# jsh-depends: cursered cursenorm filesize diffgraph googlesearch takecols reverse grouplinesbyoccurrence jgettmpdir lynx pipeboth

## The web is fuzzy:
#    - Need to kill discography listings!
#    - There are also quite a few pages containing lyrics for a group of songs

if [ ! "$*" ]
then
	echo
	echo 'seeklyrics -whatsplaying'
	echo 'seeklyrics -file <file>'
	echo
	echo '  will attempt to fill out the following automatically:'
	echo
	echo 'seeklyrics "<artist>" "<song title>" [ "<part of song>" ] [ "-<unwanted title>" ]*'
	echo
	echo '  will try to find the lyrics to the song you have specified.'
	echo
	echo '  Either of the latter two help in narrowing down on the particular song, and'
	echo '  avoiding song listings.  =)'
	echo
	echo '  Options: -oldmethod / -use <old_dir>'
	echo
	exit 1
fi

[ "$QUIET" ] || POPUP_BROWSER=true

if [ "$1" = -whatsplaying ]
then
	WHATSPLAYING=`whatsplaying`
	if [ ! "$WHATSPLAYING" ]
	then
		error "[seeklyrics] Could not find what is playing!"
		exit 1
	fi
	seeklyrics -file "$WHATSPLAYING"
	exit
elif [ "$1" = -file ]
then
	shift
	FILE="$1"
	ARTIST=
	TITLE=
	# ALBUM=
	if [ "" ] && which mp3info >/dev/null 2>&1
	then
		ARTIST=`mp3info -p "%a" "$FILE"`
		TITLE=`mp3info -p "%t" "$FILE"`
	fi
	if [ ! "$ARTIST" ] || [ ! "$TITLE" ]
	then
		jshwarn "[seeklyrics] Failed to determine artist ($ARTIST) or track ($TRACK)"
		FILENAME=`filename "$FILE"`
		jshwarn "[seeklyrics] So guessing from filename \"$FILENAME\""

		## I assume the filename's fields are delimited by '-' characters (optionally surrounded by spaces)
		FILENAME=`echo "$FILENAME" | beforelast "\."` ## Strips filename extension
		FILENAME=`echo "$FILENAME" | sed 's+([^)]*)++g'` ## Strips anything in brackets
		FILENAME=`echo "$FILENAME" | sed 's+\(^\|-\)[^[:alpha:]-]*\(-\|$\)++g'` ## Strips pure number fields (well non-text fields)
		## Rats: above regexp always kills both fields '-'s, but really we only want to kill 1 (and leave 1) unless we are doing ^ or $.

		## Clever yet stupid:
		# MINUSDELIMITERS=`echo "$FILENAME" | tr -d '-'`
		# NUMDELIMITERS=`expr \`strlen "$FILENAME"\` - \`strlen "$MINUSDELIMITERS"\``
		# if [ "$NUMDELIMITERS" -gt 1 ]
		# then
			# # ALBUM=`echo "$FILENAME" | beforefirst "[ ]*-"`
			# FILENAME=`echo "$FILENAME" | afterfirst "-[ ]*"`
		# fi
		# ARTIST=`echo "$FILENAME" | beforefirst "[ ]*-"`
		# TITLE=`echo "$FILENAME" | afterfirst "-[ ]*"`

		## TODO: What do we do if #delims = 0?

		## I assume artist is first and track name is last.
		ARTIST=`echo "$FILENAME" | beforefirst "[ ]*-"`
		TITLE=`echo "$FILENAME" | afterlast "-[ ]*"`

		# jshwarn "[seeklyrics] Guessed artist=\"$ARTIST\" title=\"$TITLE\""
	fi
	jshinfo "[seeklyrics] Got artist=\"$ARTIST\" title=\"$TITLE\""
	seeklyrics "$ARTIST" "$TITLE" ## Actually I don't think we want "$ALBUM" in the search! ## "$ALBUM" gets ignored if empty =)
	exit
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
		memo googlesearch -links "$@" "lyrics" |
		pipeboth
	`

	if [ "$POPUP_BROWSER" ]
	then
		TOP=`echo "$LINKS" | head -n 1`
		browse "$TOP" >/dev/null 2>&1
	fi

	## TODO: should strip duplicate hostnames

	for LINK in $LINKS
	do

		N=$[$N+1]

		(
			export IKNOWIDONTHAVEATTY=true ## shuts up rememo!
			# memo lynx -dump "$LINK" |
			memo downloadurl "$LINK" > $TMPDIR/$N.html

			## Could do this later...
			cat $TMPDIR/$N.html | striphtml |
			cat > $TMPDIR/$N.lyrics

			echo "$N $LINK" >&2
		) &

		sleep 1

	done

	wait

fi

echo "$N"

# for N in `seq 1 20`
for N in `seq 1 5`
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

	jshinfo "Analysing Google results for consensus..."

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
			echo "SCORE $SCORE FOR	$N.lyrics.nopun" >&2
			echo >&2

			echo "$SCORE $N"

		fi
	done |

	sort -n -k 1 |
	pipeboth |
	trimempty |
	tail -n 1 | takecols 2 > /tmp/winner.seeklyrics-$USER

	WINNER=`cat /tmp/winner.seeklyrics-$USER`
	echo "Winner was $WINNER"
	[ "$POPUP_BROWSER" ] && browse "$WINNER.html"
	# ! [ "$LINES" ] && export LINES=`echo "$LINES" - 10`
	more "$WINNER.lyrics.nopun"

fi

jshinfo "Files were saved in: $TMPDIR"

# jdeltmp $TMPDIR

