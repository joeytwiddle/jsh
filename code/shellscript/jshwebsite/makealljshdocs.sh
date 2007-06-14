OUTDIR=/var/www/jsh
mkdir -p "$OUTDIR"

COUNT=500

if [ ! "$SKIP" ]
then

	makejshwebdocs $OUTDIR/list
	makejshwebdocs -onlydocumented $OUTDIR/list-documented

fi

(

	export CGILIB_NO_CONTENT=true
	. $JPATH/code/other/cgi/cgilib || exit 129

	cd $JPATH/tools/ || exit 130

	starthtml "Recently changed jsh scripts"

	echo "This is a list of the last $COUNT scripts updated in joey's current working copy of jsh.  (Updated `date`)<BR>"
	echo "Most should be available from CVS (run updatejsh from within your copy of jsh).<BR>"
	echo "The latest scripts which aren't yet in CVS are marked; you can pick them up here if you like!<BR>"
	echo "<BR>"

	echo "<TABLE>"

	N=0

	find . -type f -follow -printf "%T@\t%p\n"|
	notindir CVS | sort -n -k 1 | afterfirst "\./" |
	tail -$COUNT | reverse |

	while read SCRIPT
	do
		N=`expr "$N" + 1`
		echo "($N/$COUNT) $SCRIPT" >&2
		echo "<TR>"
		PAGE="/jshtools/$SCRIPT"
		echo "<TD>"
		echo "<TT>"

		## Nasty hack to wrap really long names (which would otherwise make page really wide, in Konqueror anyway)
		# SHOW_SCRIPT_NAME="$SCRIPT"
		# [ `strlen "$SHOW_SCRIPT_NAME"` -gt 30 ] && SHOW_SCRIPT_NAME="<font size='-3'><tiny>$SHOW_SCRIPT_NAME</tiny></font>"
		# SEDEXP='s+..............................+\0<BR>\&nbsp;+g'
		SEDEXP="s+..............................+\0<BR>.............+g"
		SHOW_SCRIPT_NAME=`echo "$SCRIPT" | sed "$SEDEXP"`

		[ "$DEBUG" ] && debug "SED: s$SCRIPT\$<A href=\"$PAGE\">$SCRIPT</A>"
		'ls' -l -L "$SCRIPT" |
		dropcols 1 2 3 4 5 |
			# s+^.................................++
		sed "
			s+ +\&nbsp;+g
			s$SCRIPT\$<A href=\"$PAGE\">$SHOW_SCRIPT_NAME</A>
		"
		echo "</TT>"
		echo "</TD>"
		echo "<TD nowrap>"
		SCRIPTDIR=`dirname \`realpath "$SCRIPT"\``
		export CVSROOT=`cat "$SCRIPTDIR"/CVS/Root`
		STATUS=`cvs status \`realpath "$SCRIPT"\` 2>/dev/null | grep "Status: " | after "Status: "`
		if [ "$STATUS" = "Up-to-date" ]
		then : # echo "OK"
		elif [ "$STATUS" = "Unknown" ]
		# then echo "[Not yet part of Jsh]"
		then echo "[Not yet in CVS]"
		elif [ "$STATUS" = "Locally Modified" ]
		then echo "[Newer version than CVS]"
		else echo "[$STATUS!]"
		fi
		echo "</TD>"

		## Add onelinedescription:
		echo "<TD nowrap>"
		onelinedescription "$SCRIPT"
		echo "</TD>"
		
		echo "</TR>"
		# echo "<BR>"
	done

	echo "</TABLE>"

	endhtml

) | cat > "$OUTDIR/recent.html"
