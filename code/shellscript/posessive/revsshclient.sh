## Note - this script shares files with the revssh CGI script.
## On my sys, this means it must run as www-data.

## Monitor output from remote shell (passed to us by CGI script)
touch /tmp/revssh-client-output.txt /tmp/revssh-client-input.txt
# chgrp www-data /tmp/revssh-client-output.txt /tmp/revssh-client-input.txt
chmod ugo+w /tmp/revssh-client-output.txt
chmod ugo+rw /tmp/revssh-client-input.txt
# tail -f /tmp/revssh-client-output.txt &
tail -f /tmp/revssh-client-output.txt |
while read X; do
	printf "\033[00;32m"
	echo "$X"
	printf "\033[0m"
done &

## Pass user input to remote shell (well, leave it in file for CGI script to
## pass to remote revsshserver when it makes http request)
cat |
while read LINE; do
	echo "$LINE" >> /tmp/revssh-client-input.txt
	sleep 1
done

wait
