#!/bin/sh
cat > /tmp/xyz

perl -e '
	use MIME::Base64;
	$str = decode_base64("'`cat /tmp/xyz | tr -d '\n'`'");
	printf($str);
'
