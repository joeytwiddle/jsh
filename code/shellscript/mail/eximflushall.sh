mailq |

takecols 3 | grep -v '^$' |

while read MSGID
do
	echo "Asking exim to flush $MSGID"
	exim -M "$MSGID"
done
