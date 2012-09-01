# Looks for unusual net traffic and dumps it to the terminal

ignore_general="port not domain"
ignore_general="tcp"
ignore_ssh="port not ssh"
ignore_web="port not www"
ignore_irc="port not ircd and port not 6668 and port not 6669"

tcpdump -A $ignore_general and $ignore_ssh and $ignore_web and $ignore_irc

