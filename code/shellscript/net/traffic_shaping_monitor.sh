SEDSTR=`
cat << ! |
11 mail
12 crazy
13 fmail
14 int
15 web
16 other
17 wserv
18 small
19 big
!

while read NUM TYPE
do echo -n "s+$NUM:+$NUM$TYPE:+g;"
done | beforelast ";"
`

INTERFACE=`ifonline`

jwatchchanges /sbin/tc -s qdisc ls dev $INTERFACE "|" trimempty "|" sed "\"$SEDSTR\"" | highlight '[^ ]*:'
