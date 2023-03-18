#!/bin/sh


# -n = do not resolve hostnames, just show IP addresses (much faster)
# -t = show TCP
# -u = show UDP (using -tu means we don't need to grep out the annoying ^unix entries)
# -p = show process id and name
# -e = show process user
# If you want to see which local ports are listening for connections, add -l
# Mnemonics: -puten or -penult
netstat -ntupe "$@" |
#toline -x "^Active UNIX domain sockets"
#grep -v "^unix" | grep '^\(udp\|tcp\)' |
${PAGER:-less -REX}

# How to know which connections were incoming?
#
# There is no way to know after a connection is established. Once established, a TCP connection doesn't have any notions of server or client; it is symmetric.
#
# But a hacky rule-of-thumb:
#
# - If the local address has a port number < 1024, it is incoming.
#
# - Whereas if the remote address port number < 1024, it is outgoing.
#
# Source: https://www.quora.com/How-can-you-tell-which-established-connection-is-incoming-or-outgoing-in-netstat

exit

### OLD METHOD:

netstat --program |

# grep "^\(tcp\|udp\)" |

while read PROTO RECVQ SENDQ LOCALADDR REMOTEADDR STATE PIDPROGRAM
do

	LOCALPORT=`echo "$LOCALADDR" | afterlast :`

	if [ "$PROTO" = tcp ]
	then

		echo $PROTO $RECVQ $SENDQ $LOCALADDR $REMOTEADDR $STATE $PIDPROGRAM

		fuser -v $LOCALPORT/tcp |

		takecols 5 | grep -v "COMMAND" | grep -v "^$" | removeduplicatelines

	fi

done
