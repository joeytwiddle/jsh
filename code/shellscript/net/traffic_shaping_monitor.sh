SEDSTR=`
cat << ! |
11 games
12 tos
13 mail
14 int
15 ssh
16 other
17 small
18 websrv
19 big
!

while read NUM TYPE
do echo -n "s+$NUM:+$NUM$TYPE:+g;"
done | beforelast ";"
`

INTERFACE=`ifonline`

jwatchchanges -fine /sbin/tc -s qdisc ls dev $INTERFACE "|" trimempty "|" sed "\"$SEDSTR\"" | highlight '[^ ]*:'
