#!/usr/bin/env bash
set -e

# See also: https://github.com/frost-nzcr4/find_forks (same thing but in python)

origin_url="$(git remote show origin | grep 'Fetch URL:' | sed 's+.*: ++')"

full_repo_name="$(echo "$origin_url" | sed 's+.*github.com/++')"

forks_url="https://api.github.com/repos/${full_repo_name}/forks"

#[ -e "forks.json" ] ||
curl -s "$forks_url" -o forks.json

node -e "
  var forks = JSON.parse(fs.readFileSync('forks.json', 'utf-8'));
  forks.forEach(forkData => {
    // git_url stopped working with the message: The unauthenticated git protocol on port 9418 is no longer supported.
    // But we can choose one of: url, ssh_url, clone_url
    console.log('git remote add \"' + forkData.owner.login + '\" \"' + forkData.url + '\"');
  });
  console.log('git fetch --all');
" |

if [ "$1" = -do ]
then bash
else
    cat
    echo
    echo "Pass -do to execute above commands"
fi
