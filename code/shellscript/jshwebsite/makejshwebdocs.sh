if [ "$1" = -onlydocumented ]
then ONLYDOCUMENTED=true; shift
fi

if [ "$1" ]
then
	OUTDIR="$1"
	if [ ! -d "$OUTDIR" ] || [ ! -w "$OUTDIR" ]
	then
		echo "$OUTDIR is not writeable."
		exit 1
	fi
else
	OUTDIR=/tmp/jshdocs
fi

OUTDIR=`absolutepath "$OUTDIR"`
echo "Creating docs in $OUTDIR ..."
if [ -e "$OUTDIR" ]
then del "$OUTDIR"
fi

mkdir -p "$OUTDIR"

INDEXFILE="$OUTDIR/index.html"

cat > "$INDEXFILE" << !
<HTML>
<HEAD><TITLE>jsh script index</TITLE></HEAD>
<BODY>
<TABLE cellpadding='4'>
<TR bgcolor='#ffe0e0'>
<TD><B>Script category / name</B></TD>
<TD><B>Links</B></TD>
<TD></TD>
<TD><B>Brief documentation / description</B></TD>
</TR>
!

# cd "$JPATH/code/shellscript"
# find . -type f | notindir CVS | sed 's+^\./++' |

COLOR=0

cd "$JPATH/tools"
find . -type l | sed 's+^\./++' |

while read SCRIPT
do

	if [ "$ONLYDOCUMENTED" ]
	then
		if ! jdoc -hasdoc "$SCRIPT"
		then
			echo "skipping because no docs: $SCRIPT"
			continue
		fi
	fi

	SCRIPTPATH=`realpath "$SCRIPT" | afterlast "shellscript/"`
	echo "Doing $SCRIPTPATH" >&2
	PAGEFILE="$OUTDIR/$SCRIPTPATH.html"
	mkdir -p `dirname "$PAGEFILE"`

	(

		if jdoc -hasdoc "$SCRIPT"
		then

			echo "<TT>"
			jdoc showjshtooldoc "$SCRIPT" |
			striptermchars |
			tohtml
			echo "</TT>"

			echo "<HR>"

		fi

		cat "$SCRIPT" | tohtml

		echo "<HR>"

		# TODO: List scripts which depend on this one, and scripts which this one depends on.


	) |

	htmlpagewrap "jsh script: $SCRIPTPATH" > "$PAGEFILE"

	if [ $COLOR = 0 ]
	then
		ROW="<TR bgcolor='#e0e0ff'>"
		COLOR=1
	else
		ROW="<TR bgcolor='#ffffff'>"
		COLOR=0
	fi

	(
		echo "$ROW<TD>"
		echo "$SCRIPTPATH"
		echo "</TD><TD>"
		echo "(<A href=\"$SCRIPTPATH.html\">view</A>)"
		echo "</TD><TD>"
		echo "(<A href=\"http://hwi.ath.cx/cgi-bin/joey/compilejshscript?script=$SCRIPT\">compile</A>)"
		echo "</TD><TD>"
		if jdoc -hasdoc "$SCRIPT"
		# then echo "(has docs)"
		then
			# jdoc showjshtooldoc "$SCRIPT" | drop 3 | striptermchars | trimempty | head -2 | tohtml
			jdoc showjshtooldoc "$SCRIPT" | striptermchars |
			fromline -x "^::::::::" |
			fromline -x "^::::::::" |
			toline -x "^::::::::" |
			head -20 |
			trimempty |
			tohtml |
			sed 's/ /\&nbsp;/g'
		fi
		echo "</TD></TR>"
		# echo "<BR>"
	) >> "$INDEXFILE"

done

cat >> "$INDEXFILE" << !
</TABLE>
</BODY>
</HTML>
!

