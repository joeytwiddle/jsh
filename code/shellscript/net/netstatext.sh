#!/bin/sh
netstat --program |
# grep "^tcp"
toline -x "^Active UNIX domain sockets"



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
