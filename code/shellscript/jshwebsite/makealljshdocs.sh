OUTDIR=/var/www/jsh/

COUNT=200

makejshwebdocs $OUTDIR/list
makejshwebdocs -onlydocumented $OUTDIR/list-documented

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
		[ "$DEBUG" ] && debug "SED: s$SCRIPT\$<A href=\"$PAGE\">$SCRIPT</A>"
		'ls' -l -L "$SCRIPT" |
		sed "
			s+^....................................++
			s+ +\&nbsp;+g
			s$SCRIPT\$<A href=\"$PAGE\">$SCRIPT</A>
		"
		echo "</TT>"
		echo "</TD>"
		echo "<TD>"
		STATUS=`cvs status \`realpath "$SCRIPT"\` 2>/dev/null | grep "Status: " | after "Status: "`
		if [ "$STATUS" = "Up-to-date" ]
		then : # echo "OK"
		elif [ "$STATUS" = "Unknown" ]
		then echo "[Not yet part of Jsh]"
		elif [ "$STATUS" = "Locally Modified" ]
		then echo "[Newer version than CVS]"
		else echo "[$STATUS!]"
		fi
		echo "</TD>"
		echo "</TR>"
		# echo "<BR>"
	done

	echo "</TABLE>"

	endhtml

) > "$OUTDIR/recent.html"
