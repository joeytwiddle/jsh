echo "Monitoring ppp connection:"
# grep ensures secure information does not pass
/bin/su -c "tail -f /var/log/messages | grep -E \"pppd|PPP|chat\""
# "tail -f /var/log/messages"