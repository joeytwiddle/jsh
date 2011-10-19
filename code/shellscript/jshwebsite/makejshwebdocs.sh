## TODO: move deps_todo info next to compile link, where it is relevant meta-context!

# DEPENDENCY_DEBUG=2
DEPENDENCY_DEBUG=0
## 0 = Shows no dependency info
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
	[ -d "$OUTDIR" ] || verbosely mkdir -p "$OUTDIR"
	if [ ! -d "$OUTDIR" ] || [ ! -w "$OUTDIR" ]
	then
		echo "$OUTDIR is not writeable."
		exit 1
	fi
else
	OUTDIR=/tmp/jshdocs
fi

## TODO: Current: deletes itself before starting the new build.
##       Better to: make new build, then replace old build.
OUTDIR=`absolutepath "$OUTDIR"`
echo "Creating docs in $OUTDIR ..."
if [ -e "$OUTDIR" ]
then rm -rf "$OUTDIR"   ## Used to del but too many small files!
fi

mkdir -p "$OUTDIR"

INDEXFILE="$OUTDIR/index.html"
TMPINDEXFILE="$INDEXFILE.tmp"

cat > "$TMPINDEXFILE" << !
<HTML>
<HEAD><TITLE>jsh script index</TITLE></HEAD>
<BODY>
<TABLE cellpadding='4'>
<TR bgcolor='#ffe0e0'>
<TH width="20%"><B>Script category / name</B></TH>
<!-- <TH><B>Links</B></TH> -->
<TH><font color="#ffe0e0">(compile)</font></TH> <!-- makes konqueror happy -->
<!-- <TH><font color="#ffe0e0">(compile)</font></TH> --> <!-- makes konqueror happy -->
`
[ $DEPENDENCY_DEBUG -gt 3 ] &&
	echo "
<TH width="8%"><B>Jsh</B></TH>
<TH width="8%"><B>Ext</B></TH>
<TH width="8%"><B>???</B></TH>
" ||
[ $DEPENDENCY_DEBUG -gt 1 ] &&
	echo "<TH width="8%"><B>deps?</B></TH>"
`
<TH width="45%"><B>Documentation / description</B></TH>
</TR>
!

export IKNOWIDONTHAVEATTY=true ## don't know where it went, but memoing complains.

COLOR=0

# cd "$JPATH/code/shellscript"
# find . -type f | notindir CVS | sed 's+^\./++' |

cd "$JPATH/tools"
find . -type l | sed 's+^\./++' | randomorder |
# grep apt-list |

if [ "$SHOW_PROGRESS" ]
then catwithprogress
else cat
fi |

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

			echo "<PRE>"
			memo jdoc showjshtooldoc "$SCRIPT" |
			striptermchars |
			tohtml |
			sed 's+<P>+<BR>+g' ## <P> tags kill <PRE>
			echo "</PRE>"

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
					sed "s+$CHANGERE+</PRE><font color='red'><B><PRE>\1</PRE></B></font><PRE>+g"
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
			echo "Unchecked dependencies:<BR><font color='red'><B><PRE>"
			jshdepwiz gendeps "$SCRIPT" 2>&1 | striptermchars | grep -v "jshdepwiz: Checking dependencies for" | tohtml
			# echo "<!-- to help the anchor tag: -->"
			echo "</PRE></B></font>"
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
		SHOWPATH="`echo "$SCRIPTPATH" | sed 's+\(........................................\)+\1<BR>+g'`"
		echo "$ROW<TD align='left'>"
		echo "$SHOWPATH"
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
			DOC="` memo jdoc showjshtooldoc "$SCRIPT" `"
			if [ "$DOC" ]
			then
				echo "$DOC" |
				striptermchars |
				fromline -x "^::::::::" |
				fromline -x "^::::::::" |
				toline -x "^::::::::" |
				head -20 |
				trimempty |
				tohtml |
				sed 's/ /\&nbsp;/g'
			else
				echo "Doc search failed."
			fi
		fi
		echo "</TD></TR>"
		# echo "<BR>"
	) >> "$TMPINDEXFILE"

done

cat >> "$TMPINDEXFILE" << !
</TABLE>
</BODY>
</HTML>
!

verbosely mv "$TMPINDEXFILE" "$INDEXFILE"

