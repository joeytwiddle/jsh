## Note - this script shares files with the revssh CGI script.
## On my sys, this means it must run as www-data.

## Monitor output from remote shell (passed to us by CGI script)
touch /tmp/revssh-client-output.txt
chown www-data:www-data /tmp/revssh-client-output.txt
tail -f /tmp/revssh-client-output.txt &

## Pass user input to remote shell (well, leave it in file for CGI script to
## pass to remote revsshserver when it makes http request)
cat |
while read LINE; do
	echo "$LINE" >> /tmp/revssh-client-input.txt
	chown www-data:www-data /tmp/revssh-client-input.txt
	sleep 1
done
