## From: http://lartc.org/lartc.html#AEN1072

tc qdisc add dev eth0 root handle 1: htb default 30

tc class add dev eth0 parent 1: classid 1:1 htb rate 6mbit burst 15k

tc class add dev eth0 parent 1:1 classid 1:10 htb rate 5mbit burst 15k
tc class add dev eth0 parent 1:1 classid 1:20 htb rate 3mbit ceil 6mbit burst 15k
tc class add dev eth0 parent 1:1 classid 1:30 htb rate 1kbit ceil 6mbit burst 15k

## The author then recommends SFQ for beneath these classes: 
tc qdisc add dev eth0 parent 1:10 handle 10: sfq perturb 10
tc qdisc add dev eth0 parent 1:20 handle 20: sfq perturb 10
tc qdisc add dev eth0 parent 1:30 handle 30: sfq perturb 10

## Add the filters which direct traffic to the right classes: 
U32="tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32"
$U32 match ip dport 80 0xffff flowid 1:10
$U32 match ip sport 25 0xffff flowid 1:20
## And that's it - no unsightly unexplained numbers, no undocumented parameters. 
## HTB certainly looks wonderful - if 10: and 20: both have their guaranteed bandwidth, and more is left to divide, they borrow in a 5:3 ratio, just as you would expect.
## Unclassified traffic gets routed to 30:, which has little bandwidth of its own but can borrow everything that is left over. Because we chose SFQ internally, we get fairness thrown in for free!
