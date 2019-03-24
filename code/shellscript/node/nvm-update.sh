#!/bin/sh

set -e

if [ ! -d  "$HOME/.nvm" ]
then
    echo "nvm is not installed.  To install it:"
    echo
    echo "    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash"
    echo
    exit 1
fi

cd "$HOME/.nvm"

# We can only see the 'nvm_get_latest' function if we source nvm first
#. ~/.nvm/nvm.sh
#echo "Current installed version: $(nvm --version) Latest version: $(nvm_get_latest)"
#echo

echo "Fetching..."
git fetch --tags
TAG="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
echo "Checking out tag $TAG..."
git checkout "$TAG"

echo
echo "You should now reload nvm in all of your shells:"
echo
echo "    nvm unload"
echo "    source ~/.nvm/nvm.sh"
echo
