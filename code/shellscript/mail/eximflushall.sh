## See also: exim -qff

if [ "$1" = -test ]
then TEST=true
fi

mailq |

grep -v "\*\*\* frozen \*\*\*$" |

takecols 3 | grep -v '^$' |

while read MSGID
do
	echo "=============================================================================="
	mailq | grep -A2 "$MSGID"
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	# echo "## Adding debug@hwi to the recipient list of $MSGID"
	# exim -Mar "$MSGID" debug@hwi.ath.cx
	echo "## Asking exim to flush $MSGID"
	exim -v -M "$MSGID"
	# # exim -M "$MSGID"
	# # echo "## Response: $?"
	# echo "## Asking exim to remove $MSGID"
	# exim -Mrm "$MSGID"
	echo ".............................................................................."
	echo
	[ "$TEST" ] && break
done
