#!/bin/bash

# When Linux gets low on memory, earlyoom kills some Chrome tabs for me
# When Mac OS X gets low on memory, we can kill some Chrome tabs using this script

ps -o time,ppid,pid,nice,pcpu,pmem,user,args -A | sort -n -k 6 |
#wotgobblemem |

if [[ "$OSTYPE" == darwin* ]]
then grep "Google Chrome Helper" | grep -v " --extension-process "
elif [[ "$OSTYPE" == linux-gnu ]]
then grep "/chrome --type=renderer" | grep -v " --extension-process "
else grep -v ''
fi |

tail -n 5 | pipeboth | takecols 3 |
#withalldo echo
withalldo kill
