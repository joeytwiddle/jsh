COMMAND="$1"

## TODO: factor out so that list of addresses may be saved to or read from a file
##       allow a list to be built up over time even if msgs are deleted

## TODO: automatic test to ensure filter file still works
##       and recover of file if not

case "$COMMAND" in

	collectAddressesFrom)
		shift
		for MAILBOX
		do from -f "$MAILBOX"
		done |
		takecols 2 |
		removeduplicatelines
	;;

	ifMatchesAddressFrom)
		shift
		echo "if"
		echo "	this is false"
		geneximrule collectAddressesFrom "$@" |
		## FWIW, this is not a happy sed:
		# sed '
			# s+^+	or "$sender_address" is "+
			# s+$+"+
		# '
		while read ADDR
		do echo '  or "$sender_address" is "'"$ADDR"'"'
		done
		## Oh it wasn't that sed at all!
		echo
	;;

	thenSaveTo)
		shift
		DESTFILE="$1"
		echo "then"
		echo "	logwrite \"$DESTFILE [geneximrule:$RULENAME]\""
		echo "	save \"$DESTFILE\""
		echo "	seen finish"
		echo "endif"
	;;

	updaterule)
		shift
		FILTERFILE="$1"
		RULENAME="$2"
		export RULENAME; ## for use in log in thenSaveTo
		shift; shift
		NL="
"
		RULE=""
		for RULEBIT
		do RULE="$RULE$NL"`eval geneximrule $RULEBIT`
		done
		echo "New rule is:"
		echo "$RULE"
		REPLACE_STRING=" # DO NOT EDIT this line, it is the \"$RULENAME\" rule automatically updated by geneximrule"
		LINE=` echo "$RULE" | tr '\n' ' ' | tr -d '\t' `"$REPLACE_STRING"
		# echo "New line is: $LINE"
		## TODO: This is the unhappy sed; it can't handle parsing the large files which it handled creating!
		replaceline "$REPLACE_STRING" "$LINE" "$FILTERFILE"
	;;

	*)
		echo "Do not understand: $COMMAND"
	;;

esac
