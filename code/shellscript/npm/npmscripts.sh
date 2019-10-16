#!/bin/sh

npm_root="$(npm root)"

package_json="${npm_root}/../package.json"

if [ -z "$npm_root" ] || [ ! -f "$package_json" ]
then
	echo >&2 "Could not find package.json"
	exit 1
fi

if command -v jq >/dev/null
then jq .scripts package.json
else node -e "console.log(JSON.parse(require('fs').readFileSync('${package_json}')).scripts)"
# Flattened
#else node -e "console.log(Object.entries(JSON.parse(require('fs').readFileSync('${package_json}')).scripts).map(p => p.join(': ')).join('\n'))" | highlight '^.*: '
fi
