# Looks for unusual net traffic and dumps it to the terminal

## Show everything:
# filter=""
# filter="host hwi.ath.cx"
# filter="host `ppp-getip`"
# filter="tcp"
# filter="host hwi"

## Hide common stuff to see rare stuff:
# not_general="port not domain"
not_ssh="port not ssh"
not_web="port not www"
not_irc="port not ircd and port not 6668 and port not 6669"
filter="tcp and $not_ssh and $not_web and $not_irc"

tcpdump -A $filter |

# highlight '^.* < .*$' yellow |
# highlight '^.* > .*$' green |

(
	myip=`ppp-getip`
	myhostname=`host $myip | afterlast " pointer "`
	knownhost="$myhostname"
	unknownhost="[-_0-9A-Za-z.]*"
	echo "myhostname=$myhostname"
	highlight " $knownhost[0-9]* > $unknownhost" green |
	highlight "$unknownhost > $knownhost[0-9]*" yellow |
	highlight " UDP\> " magenta |
	highlight "^[0-9:.]* IP\>" white |
	cat
) |

cat

