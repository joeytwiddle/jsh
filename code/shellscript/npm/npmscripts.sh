#!/bin/sh

# See also: npm run
# See also: yarn run

project_root="$(dirname "$(npm root)")"

package_json="${project_root}/package.json"

if [ ! -f "$package_json" ]
then
	echo >&2 "Could not find package.json"
	exit 1
fi

if command -v jq >/dev/null
then jq .scripts "$package_json"
else
	#node -e "console.log(JSON.parse(require('fs').readFileSync('${package_json}')).scripts)"
	# Flattened
	#node -e "console.log(Object.entries(JSON.parse(require('fs').readFileSync('${package_json}')).scripts).map(p => p.join(': ')).join('\n'))" | highlight '^.*: '
	node -e "console.log(Object.entries(JSON.parse(require('fs').readFileSync('${package_json}')).scripts).map(p => p.join(' ')).join('\n'))" | columnise-clever -ignore '^[^ ]* *[^ ]*' | highlight -bold '^[^ ]* ' red
fi
