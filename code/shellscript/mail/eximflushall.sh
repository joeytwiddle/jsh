## See also: exim -qff

mailq |

takecols 3 | grep -v '^$' |

while read MSGID
do
	mailq | grep -A3 "$MSGID"
	# echo "## Adding debug@hwi to the recipient list of $MSGID"
	# exim -Mar "$MSGID" debug@hwi.ath.cx
	echo "## Asking exim to flush $MSGID"
	exim -v -M "$MSGID"
	# # exim -M "$MSGID"
	# # echo "## Response: $?"
	# echo "## Asking exim to remove $MSGID"
	# exim -Mrm "$MSGID"
	echo
done
