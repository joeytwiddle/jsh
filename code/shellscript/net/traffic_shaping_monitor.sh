SEDSTR=`
cat << ! |
11 mail
12 crazy
13 fmail
14 int
15 web
16 wserv
17 other
18 small
19 big
!

while read NUM TYPE
do echo -n "s+$NUM:+$NUM$TYPE:+g;"
done | beforelast ";"
`

jwatchchanges /sbin/tc -s qdisc ls dev eth1 "|" trimempty "|" sed "\"$SEDSTR\""
