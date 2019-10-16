#!/bin/sh

while true
do
	if [ -f package.json ]
	then
		if command -v jq >/dev/null
		then jq .scripts package.json
		else node -e "console.log(JSON.parse(require('fs').readFileSync('./package.json')).scripts)"
		# Flattened
		#else node -e "console.log(Object.entries(JSON.parse(require('fs').readFileSync('./package.json')).scripts).map(p => p.join(': ')).join('\n'))" | highlight '^.*: '
		fi
		exit "$?"
	fi
	if [ "$PWD" = / ]
	then
		echo >&2 "Could not find package.json"
		exit 1
	fi
	cd ..
done
