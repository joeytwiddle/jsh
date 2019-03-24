# From: http://codegolf.stackexchange.com/questions/44278/debunking-stroustrups-debunking-of-the-myth-c-is-for-large-complicated-pro#44317

domain="www.stroustrup.com"
path="C++.html"
exec 3<> /dev/tcp/$domain/80
printf "GET /$path HTTP/1.1\r\nhost: %s\r\nConnection: close\r\n\r\n" "$domain" >&3
while read -u3; do
	if [[ "$REPLY" =~ http://[^\"]* ]]; then
		printf '%s\n' "$BASH_REMATCH"
	fi
done
