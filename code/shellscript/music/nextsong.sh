## TODO: jmusic should have lock/active/run-file

## Should be whichmediaplayer
xmmsisplaying () {
	top c | head -15 | grep xmms > /dev/null
}

if xmmsisplaying
then xmms -f
else killall mpg123 ## send it something softer
fi
