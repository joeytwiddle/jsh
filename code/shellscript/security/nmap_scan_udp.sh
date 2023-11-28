# Just a reminder how to check UDP ports
#
# sudo: Must run as root to send/receive UDP
#
# -Pn: For many hosts you need to skip nmap's initial ping probe step, because they have disabled ICMP pings to evade automated discovery.  Otherwise you may see "Host seems down" response.
# -sS: Check TCP only (default behaviour)
# -sSU: Check TCP and UDP
# -sU: Check UDP only
#
# -PS: TCP SYN/ACK discovery (whatever that is!)
#
# -sV -sC: Service version detection, and service details, respectively
#
# In my experience, many UDP ports return open|filtered regardless whether they are listening or not!  So I find TCP scans much more informative.
#
sudo nmap -Pn -sSU "$@"
