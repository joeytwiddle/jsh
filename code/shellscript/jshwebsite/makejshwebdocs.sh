## TODO: move deps_todo info next to compile link, where it is relevant meta-context!

DEPENDENCY_DEBUG=2
## 1 = Shows dependency info in each script's view page
## 2 = Shows Todo column in index page
## 3 = Highlights unchecked dependencies in view page
## 4 = Shows all dependency info in index page

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
<TD width="20%"><B>Script category / name</B></TD>
<!-- <TD><B>Links</B></TD> -->
<TD><font color="#ffe0e0">(compile)</font></TD> <!-- makes konqueror happy -->
<!-- <TD><font color="#ffe0e0">(compile)</font></TD> --> <!-- makes konqueror happy -->
`
[ $DEPENDENCY_DEBUG -gt 3 ] &&
	echo "
<TD width="8%"><B>Jsh</B></TD>
<TD width="8%"><B>Ext</B></TD>
<TD width="8%"><B>???</B></TD>
" ||
[ $DEPENDENCY_DEBUG -gt 1 ] &&
	echo "<TD width="8%"><B>deps?</B></TD>"
`
<TD width="35%"><B>Documentation / description</B></TD>
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

	## Generate page for this script:

	(

		# cat "$SCRIPT" | tohtml

		# if jdoc -hasdoc "$SCRIPT"
		if true
		then

			echo "<TT>"
			memo jdoc showjshtooldoc "$SCRIPT" |
			striptermchars |
			tohtml |
			sed 's+<P>+<BR>+g' ## <P> tags kill <TT>
			echo "</TT>"

			echo "<HR>"

		fi |

		(

			if [ $DEPENDENCY_DEBUG -gt 2 ]
			then
				export DEPWIZ_NON_INTERACTIVE=true
				UNRESOLVED=`jshdepwiz gendeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tr '\n' ' '`
				if [ "$UNRESOLVED" ]
				then
					CHANGERE="\<\("`echo "$UNRESOLVED" | sed 's+\?[ ]*+\\\|+g' | sed 's+\\\\|$++'`"\)\>"
					echo "$CHANGERE" >&2
					sed "s+$CHANGERE+</TT><font color='red'><B><TT>\1</TT></B></font><TT>+g"
				else
					cat
				fi
			else
				cat
			fi

		)

		echo "<HR>"

		echo "<A name="about">"

		if [ $DEPENDENCY_DEBUG -gt 0 ]
		then
			export DEPWIZ_NON_INTERACTIVE=true
			## Detailed version; re-enable when DHTML/Javascript "hide column" feature available
			echo "Jsh dependencies:<BR>"
			jshdepwiz getjshdeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
			echo "<BR>"
			echo "External dependencies:<BR>"
			jshdepwiz getextdeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
			echo "<BR>"
			echo "Unchecked dependencies:<BR><font color='red'><B><TT>"
			jshdepwiz gendeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
			# echo "<!-- to help the anchor tag: -->"
			echo "</TT></B></font>"
			echo "<BR>"
			echo "&nbsp;"
			echo "<BR>"
			echo "&nbsp;"
		fi

	) |

	htmlpagewrap "jsh script: $SCRIPTPATH" > "$PAGEFILE"

	## Add this script to the index:

	if [ $COLOR = 0 ]
	then
		ROW="<TR bgcolor='#e0e0ff'>"
		COLOR=1
	else
		ROW="<TR bgcolor='#ffffff'>"
		COLOR=0
	fi

	(
		echo "$ROW<TD align='left'>"
		echo "$SCRIPTPATH"
		echo "</TD><TD align='center'>"
		echo "(<A href=\"$SCRIPTPATH.html\">view</A>)"
		# echo "</TD><TD align='center'>"
		echo "(<A href=\"http://hwi.ath.cx/cgi-bin/joey/compilejshscript?script=$SCRIPT\">download</A>)"
		if [ $DEPENDENCY_DEBUG -gt 1 ]
		then
			echo "</TD><TD align='center'>"
			# export DEPWIZ_VIGILANT=true
			export DEPWIZ_NON_INTERACTIVE=true
			if [ $DEPENDENCY_DEBUG -gt 3 ]
			then
				## Detailed version; re-enable when DHTML/Javascript "hide column" feature available
				jshdepwiz getjshdeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
				echo "</TD><TD align='center'>"
				jshdepwiz getextdeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
				echo "</TD><TD align='center'>"
				jshdepwiz gendeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
			else
				jshdepwiz gendeps "$SCRIPT" > /dev/null 2>&1 &&
				echo "known" ||
				echo "<A href=\"$SCRIPTPATH.html#about\">todo</A>"
			fi
		fi
		echo "</TD><TD>"
		if jdoc -hasdoc "$SCRIPT"
		# then echo "(has docs)"
		then
			# jdoc showjshtooldoc "$SCRIPT" | drop 3 | striptermchars | trimempty | head -2 | tohtml
			memo jdoc showjshtooldoc "$SCRIPT" | striptermchars |
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

