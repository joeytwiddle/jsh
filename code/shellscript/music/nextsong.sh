## TODO: jmusic should have lock/active/run-file?

## Should be whichmediaplayer
xmmsisplaying () {
	top c n 1 b | head -50 | grep xmms > /dev/null
}

if xmmsisplaying
then xmms -f
else killall mpg123 ## send it something softer
fi
