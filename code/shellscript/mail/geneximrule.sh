#!/bin/sh
COMMAND="$1"

## BUG: can't handle really long lists of email addresses.  Needs fixing!  See below.

## TODO: factor out so that list of addresses may be saved to or read from a file
##       allow a list to be built up over time even if msgs are deleted

## TODO: automatic test to ensure filter file still works
##       and recover of file if not

## Unfortunately this script is becoming less useful as some mailers generate a
## unique origin address for each mail they send.  We may want to try picking
## out a different field to filter on.  Unfortunately 'from' does not appear to
## have any options for this.
## We could try grepping mail folders ourself for ^Return-path: or ^From:

case "$COMMAND" in

	collectAddressesFrom)
		shift
		for MAILBOX
		do from -f "$MAILBOX"
		done |
		takecols 2 |
		removeduplicatelines |
		## But there are a couple of mail addresses we don't ever want to collect:
		# Those "do not delete me" messages which sometimes appear in folders come from this guy
		grep -v '^MAILER-DAEMON$' |
		# Sometimes I get a mail from someone else but via myself.  It's not stupid, it's advanced.
		grep -v '^joey@hwi$'
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
		echo "	logwrite \">>> $DESTFILE [geneximrule:$RULENAME] [sender_address=\$sender_address]\""
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
		curseblue
		echo "New rule is:"
		echo "$RULE"
		cursenorm
		REPLACE_STRING=" # DO NOT EDIT this line, it is the \"$RULENAME\" rule automatically updated by geneximrule"
		LINE=` echo "$RULE" | tr '\n' ' ' | tr -d '\t' `"$REPLACE_STRING"
		# echo "New line is: $LINE"
		## TODO: This is the unhappy sed; it can't handle parsing the large files which it handled creating!
		replaceline "$REPLACE_STRING" "$LINE" "$FILTERFILE"
		## TODO: Yeah the sed is slow, but worse than that, replaceline/sed can't handle the really huge lines I want to give it.
		## TODO: Fortunately somehow, it just leaves the "this is false" condition so the filter file doesn't break.
		## TODO: It has taken out my blacklist and will take out other lists as they grow, or until I fix it.
		## /home/joey/linux/j/tools/geneximrule: line 65: /home/joey/linux/j/tools/replaceline: Argument list too long
	;;

	*)
		echo "Do not understand: $COMMAND"
	;;

esac
