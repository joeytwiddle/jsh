dar -d `dpkg -L "$1"` | grep -v '/$'
