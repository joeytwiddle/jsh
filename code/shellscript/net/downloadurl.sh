if `jwhich -quietly wget`
then wget -O - "$@"
elif `jwhich -quietly lynx`
then lynx -source "$@"
else
	error "downloadurl: neither wget nor lynx present, no telnet implemented."
	exit 1
fi
