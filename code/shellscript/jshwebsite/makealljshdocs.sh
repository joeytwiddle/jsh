OUTDIR=/var/www/jsh/

makejshwebdocs $OUTDIR/list
makejshwebdocs -onlydocumented $OUTDIR/list-documented

(

	export CGILIB_NO_CONTENT=true
	. $JPATH/code/other/cgi/cgilib || exit 129

	cd $JPATH/tools/ || exit 130

	starthtml "Recently changed jsh scripts"

	echo "This is a list of the last 500 scripts updated in joey's current working copy of jsh.  (Updated `date`)<BR>"
	echo "Those scripts which have been committed to CVS can be obtained by running updatejsh from your working copy.<BR>"
	echo "<BR>"

	find . -type f -follow -printf "%T@\t%p\n"|
	notindir CVS | sort -n -k 1 | afterfirst "\./" |
	tail -500 | reverse |

	while read SCRIPT
	do
		PAGE="/jshtools/$SCRIPT"
		echo "<TT>"
		'ls' -l -L "$SCRIPT" |
		sed "
			s+^....................................++
			s+ +\&nbsp;+g
			s+$SCRIPT\$+<A href=\"$PAGE\">$SCRIPT</A>+
		"
		echo "</TT>"
		if cvs status `realpath "$SCRIPT"` | grep "Status: Up-to-date" >/dev/null
		then :
		else echo "[Not yet in CVS]"
		fi
		echo "<BR>"
	done

	endhtml

) > "$OUTDIR/recent.html"
